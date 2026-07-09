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
FROM jgaltidor/sudoku_solver_service_inez:latest

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
