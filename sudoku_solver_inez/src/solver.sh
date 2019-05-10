#! /usr/bin/env bash
SUDOKU_SOLVER_SRC=$(dirname "$0")
INEZ=$HOME/custominstalls/inez_pkg/inez
SCIP_SUITE_DIR=$HOME/custominstalls/inez_pkg/scipoptsuite-3.1.1
# For OS X
export DYLD_FALLBACK_LIBRARY_PATH=$SCIP_SUITE_DIR/lib:$DYLD_FALLBACK_LIBRARY_PATH
# For Linux
export LD_LIBRARY_PATH=$SCIP_SUITE_DIR/lib:$LD_LIBRARY_PATH
export TMPDIR=$HOME/tmp
eval `opam config env`
$INEZ/frontend/inez.top -noprompt \
  -I $INEZ/frontend \
  -I $SUDOKU_SOLVER_SRC \
  -init $SUDOKU_SOLVER_SRC/solver.init < $*
