curl -H "Content-Type: application/json" \
  -X POST \
  -d '{ "board" : [[2, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0],
                   [0, 0, 0,  0, 0, 0,  0, 0, 0]
                  ]}' \
  http://localhost:8080/