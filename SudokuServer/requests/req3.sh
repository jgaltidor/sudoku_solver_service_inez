curl -H "Content-Type: application/json" \
  -X POST \
  -d '{ "board" : [[0, 3, 0,  2, 0, 0,  0, 0, 6],
                   [0, 0, 0,  0, 0, 9,  0, 0, 4],
                   [7, 6, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 5, 0,  7, 0, 0],
                   [0, 0, 0,  0, 0, 1,  8, 6, 0],
                   [0, 5, 0,  4, 8, 0,  0, 9, 0],
                   [8, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 7, 6,  0, 0, 0],
                   [0, 7, 5,  0, 0, 8,  1, 0, 0]
                  ]}' \
  http://localhost:8080/
