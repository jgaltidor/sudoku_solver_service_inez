# Use an official Python runtime as a parent image
FROM ubuntu:16.04

ARG HOME=/home/dev

RUN useradd --home-dir $HOME --create-home --shell /bin/bash dev
USER dev
WORKDIR $HOME
# ENV HOME $HOME

USER root

SHELL ["/bin/bash", "-i", "-l", "-c"]

# Copy this directory contents into the container at directory /app
COPY . ${HOME}/app

RUN chown -R dev:dev ${HOME}/app

# package tzdata is needed because ocaml_plugin
# reads file /etc/localtime. This file is a broken
# symbolic link if tzdata is not installed

# Install software dependencies
RUN apt-get -y update && apt-get -y install --no-install-recommends \
  tzdata \
  ocaml \
  opam \
  ocaml-native-compilers \
  camlp4-extra \
  m4 \
  libboost-all-dev \
  wget \
  git \
  emacs \
  rlwrap \
  curl \
  less \
  rsync \
  openssh-client \
  unzip \
  ca-certificates \
  dos2unix

# Install Java 11

RUN apt-get install -y software-properties-common

RUN add-apt-repository ppa:openjdk-r/ppa -y

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    maven

# Performing installs that don't require root permissions

USER dev

ARG SUDOKU_SERVICE=${HOME}/app

# Build Sudoku Server

ARG SUDOKU_SERVER=${SUDOKU_SERVICE}/SudokuServer

WORKDIR ${SUDOKU_SERVER}

RUN mvn package

# Install Inez dependencies

# Build SCIP libary. Inez depends on SCIP

ARG SCIP=${HOME}/app/libs/scipoptsuite-3.1.1
ARG SCIP_LIB=${SCIP}/lib

# libs/scipoptsuite-3.1.1 is tracked as a single archive (libs/scipoptsuite-3.1.1.tgz)
# rather than an extracted tree. Extract it here; its own Makefile in turn
# auto-extracts the nested scip-3.1.1/soplex-2.0.1/zimpl-3.3.2 archives it
# contains on demand when "make scipoptlib" runs below.
RUN tar xzf ${HOME}/app/libs/scipoptsuite-3.1.1.tgz -C ${HOME}/app/libs

WORKDIR ${SCIP}

RUN make scipoptlib \
      SHARED=true \
      READLINE=false \
      ZLIB=false \
      GMP=false \
      ZIMPL=false && \
    ln -s \
      ${SCIP_LIB}/libscipopt-3.1.1.linux.x86_64.gnu.opt.so \
      ${SCIP_LIB}/libscipopt.so

ENV LD_LIBRARY_PATH ${SCIP_LIB}

# Install OCaml dependencies

RUN opam init --yes --auto-setup && \
  eval `opam config env` && \
  opam update && \
  opam pin --yes add core 112.35.01

RUN eval `opam config env` && \
  opam install --yes \
    async \
    camlidl \
    camlp4 \
    comparelib \
    core \
    herelib \
    ocamlfind \
    ocaml_plugin \
    omake \
    sexplib \
    yojson


# Build Inez

ARG INEZ=${HOME}/app/libs/inez

WORKDIR ${INEZ}

# libs/inez is a git submodule of github.com/vasilisp/inez, so its own
# OMakefile.config (which has machine-specific paths, and is gitignored
# upstream) isn't part of it. This repo tracks a copy pre-filled with the
# paths this image actually uses (HOME=/home/dev, opam's "system" switch).
RUN cp ${HOME}/app/docker/inez-OMakefile.config ${INEZ}/OMakefile.config

RUN  eval `opam config env` && \
       omake frontend/inez.opt && \
       omake frontend/inez.top


# Build sudoku_solver_inez


ARG SUDOKU_INEZ=${SUDOKU_SERVICE}/sudoku_solver_inez

WORKDIR ${SUDOKU_INEZ}/src

RUN eval `opam config env` && omake

ENV SUDOKU_SERVICE=$SUDOKU_SERVICE

# Make SUDOKU_SERVER port 8080 available to the world outside this container
EXPOSE 8080

WORKDIR ${SUDOKU_SERVICE}/SudokuServer

# Launch Sudoku Web Services. cwd matters here: sudoku_server.conf's
# solver_script_file (../sudoku_solver_inez/src/run_solver.sh) and its bare
# sudoku_config.json/sudoku_output.json paths are resolved relative to the
# JVM's working directory, not to SudokuServer.jar's own location.
CMD ["./run.sh"]

