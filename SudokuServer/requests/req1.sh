curl -H "Content-Type: application/json" \
  -X POST \
  -d '{ "board" : [[0, 0, 4,  0, 7, 8,  0, 1, 2], [0, 7, 2,  1, 0, 5,  3, 0, 8], [1, 9, 0,  3, 4, 2,  5, 6, 0], [8, 0, 9,  7, 6, 1,  0, 2, 3], [4, 2, 6,  8, 5, 3,  7, 0, 0], [0, 1, 0,  9, 2, 4,  8, 5, 6], [9, 0, 1,  5, 3, 0,  2, 8, 4], [2, 8, 7,  0, 1, 9,  6, 0, 5], [0, 4, 5,  0, 8, 6,  1, 7, 0]]}' \
  http://localhost:8080/