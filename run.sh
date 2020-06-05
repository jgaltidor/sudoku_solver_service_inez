#! /usr/bin/env bash
BASEDIR=$(dirname "$0")
echo "Launching Backend Sudoku Service"
pushd $BASEDIR/SudokuServer
./run.sh &
popd
pushd $BASEDIR/sudoku_ui_prj/sudoku-ui
echo "Launching Frontend Sudoku UI Web Server"
npm start
popd
