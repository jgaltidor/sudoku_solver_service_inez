# Modern glibc/libstdc++ sysroot, used only to satisfy VS Code Server's
# runtime requirements (glibc >= 2.28, libstdc++ >= 3.4.25). Isolated under
# /opt/vscode-glibc in the final image; nothing else here uses it, so the
# Inez/OCaml/SCIP build below keeps running against the original xenial
# system glibc it was actually built and tested against.
FROM ubuntu:22.04 AS vscode-glibc-sysroot

RUN apt-get update && apt-get install -y --no-install-recommends patchelf && \
    rm -rf /var/lib/apt/lists/*

# patchelf itself is a jammy binary and needs jammy's glibc/libstdc++ to run,
# but its own interpreter/rpath still point at the default system paths, not
# our /opt/vscode-glibc copy below. Patch a copy (patchelf refuses to rewrite
# its own currently-executing file: "Text file busy") now, while jammy's own
# libs are still the ones in effect, to point at the path we'll copy it to,
# so it is self-sufficient once it lands in the xenial-based final image.
RUN cp /usr/bin/patchelf /usr/local/bin/patchelf-portable && \
    patchelf \
      --set-interpreter /opt/vscode-glibc/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
      --set-rpath /opt/vscode-glibc/usr/lib/x86_64-linux-gnu \
      /usr/local/bin/patchelf-portable

# Your existing old base image
FROM jgaltidor/sudoku-solver-backend:latest

USER root

COPY --from=vscode-glibc-sysroot /usr/lib/x86_64-linux-gnu /opt/vscode-glibc/usr/lib/x86_64-linux-gnu
COPY --from=vscode-glibc-sysroot /usr/local/bin/patchelf-portable /opt/vscode-glibc/bin/patchelf

# Point VS Code Server at the sysroot above instead of the container's
# xenial glibc/libstdc++. Setting VSCODE_SERVER_CUSTOM_GLIBC_LINKER also
# makes VS Code Server skip its own pre-flight requirements check, which
# would otherwise (correctly) refuse to run against the system glibc.
# https://code.visualstudio.com/docs/remote/faq
# https://github.com/microsoft/vscode/blob/main/resources/server/bin/helpers/check-requirements-linux.sh
ENV VSCODE_SERVER_CUSTOM_GLIBC_LINKER=/opt/vscode-glibc/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
ENV VSCODE_SERVER_CUSTOM_GLIBC_PATH=/opt/vscode-glibc/usr/lib/x86_64-linux-gnu
ENV VSCODE_SERVER_PATCHELF_PATH=/opt/vscode-glibc/bin/patchelf

# The published backend image no longer carries Node (the frontend build was
# split into its own image/service, see docker-compose.yml). Modern Node
# (18+, required by Vite) can't actually run on this xenial base at all --
# its prebuilt binaries need glibc >= 2.27/2.28, same constraint as VS Code
# Server above, and unlike VS Code Server there's no equivalent
# patchelf-to-/opt/vscode-glibc trick that's worth the fragility here (Vite's
# own dependency tree pulls in several more native binaries, e.g. esbuild/
# rollup, that would each need the same patching). Instead of installing
# Node here, give the container a Docker CLI so `docker compose up frontend`
# (run from this devcontainer's own terminal, see devcontainer.json's socket
# mount + postStartCommand) starts the frontend as a sibling container using
# its own already -- and genuinely -- modern node:20 image.
#
# The official devcontainers "docker-outside-of-docker" feature would
# normally handle this, but it refuses to run at all on xenial (its
# apt-based moby/docker-ce install path only supports a fixed allowlist of
# newer distro codenames -- xenial isn't in it, even with "moby": false).
# Install the plain static docker CLI + compose plugin binaries instead --
# they're statically linked Go binaries, so this xenial image's old glibc
# doesn't matter here the way it does for Node.
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-29.6.1.tgz \
      -o /tmp/docker.tgz && \
    tar -xzf /tmp/docker.tgz -C /tmp && \
    mv /tmp/docker/docker /usr/local/bin/docker && \
    rm -rf /tmp/docker.tgz /tmp/docker

RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -fsSL https://github.com/docker/compose/releases/download/v5.3.1/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# The host's docker.sock (mounted in by devcontainer.json) is root-owned,
# group "root", mode 660 (group-writable, no other access) -- remoteUser
# john isn't in that group, so it can't reach the daemon through it as-is.
# devcontainer.json's postStartCommand chowns the socket's group to john at
# container *start* time instead (can't be baked into the image; the bind
# mount only exists once the container is actually running). That step
# needs root, and postStartCommand runs as remoteUser (john); scope sudo to
# just the commands that step actually runs, not blanket root access.
#
# Two earlier versions of this fix were both wrong in different ways:
# - Adding john to the socket's *existing* group (whose GID varies by
#   host/Docker install, so it had to be resolved and joined via
#   groupadd/usermod at container-start time) doesn't work: supplementary
#   group membership is only re-read from /etc/group on a fresh login, but
#   VS Code terminals aren't fresh logins -- they're forked from the
#   long-lived vscode-server process, which typically starts within a
#   second of the container (often before this step finishes). Any
#   terminal opened in that window stayed permanently denied for the rest
#   of the VS Code session, even after the group-add step visibly
#   succeeded.
# - `chmod 666 /var/run/docker.sock` avoids that race (the kernel
#   re-evaluates a file-mode check on every syscall, so it can't go stale
#   per-process the way group membership can) but overshoots: docker.sock
#   is a `type=bind` mount, so chmod-ing it inside the container mutates
#   the *real* host-side (or Docker Desktop VM) socket file's permission
#   bits, not a container-local copy, leaving it world-read/write to every
#   process on the host/VM, not just john -- a much bigger exposure than
#   intended, and it persists after the devcontainer itself stops.
# Instead, chown the socket's *group* to john -- not a supplementary group
# john has to be added to at runtime, but john's own primary group (fixed
# at image-build time via `useradd`, gid 1000, see root Dockerfile), so
# every process running as john already carries it from exec, with no
# login-session/staleness dependency at all. Mode stays at its default 660
# (group read/write), so only root and john (via that chown) can reach the
# socket -- no wider than the original group-based approach intended, and
# without chmod's world-writable side effect.
# postStartCommand execs non-interactively (no pseudo-TTY), and xenial's
# default sudo still enforces requiretty even for NOPASSWD entries -- scope
# the tty exemption to john specifically, not a global Defaults change.
#
# The other NOPASSWD entry (chmod on /vscode) works around a separate issue:
# /vscode is VS Code Dev Containers' own shared, cross-project server-install
# cache volume (named "vscode", external=true -- not something this project
# creates or owns). It extracts the VS Code Server tarball as root, leaving
# `node` and friends mode 755 (no group/other write). VS Code's own
# self-patch step (triggered by VSCODE_SERVER_CUSTOM_GLIBC_LINKER etc. above)
# then tries to rewrite that same `node` binary in place as remoteUser
# (john) to point it at /opt/vscode-glibc -- which fails with "Permission
# denied" since john doesn't own it, and VS Code's patch script doesn't check
# patchelf's exit code, so it silently reports "Patching complete" anyway and
# the stale unpatched binary keeps failing the same old-glibc check forever.
# Loosening perms on the whole cache on every start means: the very first
# time a new VS Code Server commit is downloaded the connection can still
# fail once, but the next start (or "Dev Containers: Reopen") self-heals,
# since the postStartCommand below runs before VS Code tries to attach again.
RUN apt-get update && apt-get install -y --no-install-recommends sudo && \
    rm -rf /var/lib/apt/lists/* && \
    { echo "john ALL=(root) NOPASSWD: /bin/chown root:john /var/run/docker.sock, /bin/chmod -R a+rwX /vscode"; \
      echo "Defaults:john !requiretty"; } > /etc/sudoers.d/john && \
    chmod 0440 /etc/sudoers.d/john

USER john
