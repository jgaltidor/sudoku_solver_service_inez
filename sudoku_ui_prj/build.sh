npx create-react-app sudoku-ui
cp -r sudoku-ui-src/* sudoku-ui/.
pushd sudoku-ui
npm install
npm install fetch
npm audit fix
popd
