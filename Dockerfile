# Use an official Python runtime as a parent image
FROM ubuntu:16.04

ARG HOME=/home/john

RUN useradd --home-dir $HOME --create-home --shell /bin/bash john
USER john
WORKDIR $HOME
# ENV HOME $HOME

USER root

# Copy this directory contents into the container at directory /app
COPY . ${HOME}/app

RUN chown -R john:john ${HOME}/app

# package tzdata is needed because ocaml_plugin
# reads file /etc/localtime. This file is a broken
# symbolic link if tzdata is not installed

# Install software dependencies
RUN apt-get -y update && apt-get -y install \
  tzdata \
  ocaml \
  opam \
  ocaml-native-compilers \
  m4 \
  libboost-all-dev \
  wget \
  git \
  emacs \
  rlwrap \
  default-jdk \
  maven \
  curl

# Install sudoku ui server dependency: Node.js/ReactJS

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs

# Install Inez dependencies

USER john

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

# Build SCIP libary. Inez depends on SCIP

ARG SCIP=${HOME}/app/libs/scipoptsuite-3.1.1

WORKDIR ${SCIP}

RUN make scipoptlib \
      SHARED=true \
      READLINE=false \
      ZLIB=false \
      GMP=false \
      ZIMPL=false && \
    ln -s \
      ${SCIP}/lib/libscipopt-3.1.1.linux.x86_64.gnu.opt.so \
      ${SCIP}/lib/libscipopt.so

ENV LD_LIBRARY_PATH ${SCIP}/lib

# Build Inez

ARG INEZ=${HOME}/app/libs/inez

WORKDIR ${INEZ}

RUN  eval `opam config env` && \
       omake frontend/inez.opt && \
       omake frontend/inez.top

ARG SUDOKU_SERVICE=${HOME}/app/sudoku_solver_service_inez

# Build sudoku_solver_inez

ARG SUDOKU_INEZ=${SUDOKU_SERVICE}/sudoku_solver_inez

WORKDIR ${SUDOKU_INEZ}/src

RUN eval `opam config env` && omake

# Build Sudoku Server

ARG SUDOKU_SERVER=${SUDOKU_SERVICE}/SudokuServer

WORKDIR ${SUDOKU_SERVER}

RUN mvn package

# Build Sudoku UI Server

ARG SUDOKU_UI=${SUDOKU_SERVICE}/sudoku_ui_prj

WORKDIR ${SUDOKU_UI}

RUN npx create-react-app sudoku-ui && \
    cp -r sudoku-ui-src/* sudoku-ui/.

WORKDIR ${SUDOKU_UI}/sudoku-ui

RUN npm install fetch

WORKDIR ${SUDOKU_SERVICE}

# Make SUDOKU_UI port 3000 available to the world outside this container
EXPOSE 3000

# Make SUDOKU_SERVER port 8080 available to the world outside this container
EXPOSE 8080

ENV SUDOKU_SERVICE=$SUDOKU_SERVICE

# Launch Sudoku Web Services
# ENTRYPOINT ${SUDOKU_SERVICE}/run.sh

# Run bash when the container launches
# CMD ["bash"]

