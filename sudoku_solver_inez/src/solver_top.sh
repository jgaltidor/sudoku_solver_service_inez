#! /usr/bin/env bash
SUDOKU_SOLVER_SRC=$(dirname "$0")
INEZ=$HOME/custominstalls/inez_pkg/inez
SCIP_SUITE_DIR=$HOME/custominstalls/inez_pkg/scipoptsuite-3.1.1
export LD_LIBRARY_PATH=$SCIP_SUITE_DIR/lib:$LD_LIBRARY_PATH
eval `opam config env`
$INEZ/frontend/inez.top \
  -I $INEZ/frontend \
  -I $SUDOKU_SOLVER_SRC \
  -init $SUDOKU_SOLVER_SRC/solver.init $*
