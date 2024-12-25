import gleam/dict.{type Dict}

pub type DirectionButton {
  Up
  Down
  Left
  Right
  A
}

pub type NumericPathDict =
  Dict(String, Dict(String, List(DirectionButton)))

pub type DirectionalPathDict =
  Dict(DirectionButton, Dict(DirectionButton, List(DirectionButton)))

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
pub fn numeric_keypad_path_dict() -> NumericPathDict {
  dict.from_list([
    #(
      "7",
      dict.from_list([
        #("7", []),
        #("8", [Right]),
        #("9", [Right, Right]),
        #("4", [Down]),
        #("5", [Right, Down]),
        #("6", [Right, Right, Down]),
        #("1", [Down, Down]),
        #("2", [Right, Down, Down]),
        #("3", [Right, Right, Down, Down]),
        #("0", [Right, Down, Down, Down]),
        #("A", [Right, Right, Down, Down, Down]),
      ]),
    ),
    #(
      "8",
      dict.from_list([
        #("7", [Left]),
        #("8", []),
        #("9", [Right]),
        #("4", [Down, Left]),
        #("5", [Down]),
        #("6", [Right, Down]),
        #("1", [Down, Down, Left]),
        #("2", [Down, Down]),
        #("3", [Right, Down, Down]),
        #("0", [Down, Down, Down]),
        #("A", [Right, Down, Down, Down]),
      ]),
    ),
    #(
      "9",
      dict.from_list([
        #("7", [Left, Left]),
        #("8", [Left]),
        #("9", []),
        #("4", [Down, Left, Left]),
        #("5", [Down, Left]),
        #("6", [Down]),
        #("1", [Down, Down, Left, Left]),
        #("2", [Down, Down, Left]),
        #("3", [Down, Down]),
        #("0", [Down, Down, Down, Left]),
        #("A", [Down, Down, Down]),
      ]),
    ),
    #(
      "4",
      dict.from_list([
        #("7", [Up]),
        #("8", [Up, Right]),
        #("9", [Up, Right, Right]),
        #("4", []),
        #("5", [Right]),
        #("6", [Right, Right]),
        #("1", [Down]),
        #("2", [Right, Down]),
        #("3", [Right, Right, Down]),
        #("0", [Right, Down, Down]),
        #("A", [Right, Right, Down, Down]),
      ]),
    ),
    #(
      "5",
      dict.from_list([
        #("7", [Up, Left]),
        #("8", [Up]),
        #("9", [Up, Right]),
        #("4", [Left]),
        #("5", []),
        #("6", [Right]),
        #("1", [Down, Left]),
        #("2", [Down]),
        #("3", [Right, Down]),
        #("0", [Down, Down]),
        #("A", [Right, Down, Down]),
      ]),
    ),
    #(
      "6",
      dict.from_list([
        #("7", [Up, Left, Left]),
        #("8", [Up, Left]),
        #("9", [Up]),
        #("4", [Left, Left]),
        #("5", [Left]),
        #("6", []),
        #("1", [Down, Left, Left]),
        #("2", [Down, Left]),
        #("3", [Down]),
        #("0", [Down, Down, Left]),
        #("A", [Down, Down]),
      ]),
    ),
    #(
      "1",
      dict.from_list([
        #("7", [Up, Up]),
        #("8", [Up, Up, Right]),
        #("9", [Up, Up, Right, Right]),
        #("4", [Up]),
        #("5", [Up, Right]),
        #("6", [Up, Right, Right]),
        #("1", []),
        #("2", [Right]),
        #("3", [Right, Right]),
        #("0", [Right, Down]),
        #("A", [Right, Right, Down]),
      ]),
    ),
    #(
      "2",
      dict.from_list([
        #("7", [Up, Up, Left]),
        #("8", [Up, Up]),
        #("9", [Up, Up, Right]),
        #("4", [Up, Left]),
        #("5", [Up]),
        #("6", [Up, Right]),
        #("1", [Left]),
        #("2", []),
        #("3", [Right]),
        #("0", [Down]),
        #("A", [Right, Down]),
      ]),
    ),
    #(
      "3",
      dict.from_list([
        #("7", [Left, Left, Up, Up]),
        #("8", [Left, Up, Up]),
        #("9", [Up, Up]),
        #("4", [Left, Left, Up]),
        #("5", [Left, Up]),
        #("6", [Up]),
        #("1", [Left, Left]),
        #("2", [Left]),
        #("3", []),
        #("0", [Down, Left]),
        #("A", [Down]),
      ]),
    ),
    #(
      "0",
      dict.from_list([
        #("7", [Up, Left, Up, Up]),
        #("8", [Up, Up, Up]),
        #("9", [Up, Up, Up, Right]),
        #("4", [Up, Left, Up]),
        #("5", [Up, Up]),
        #("6", [Up, Up, Right]),
        #("1", [Up, Left]),
        #("2", [Up]),
        #("3", [Up, Right]),
        #("0", []),
        #("A", [Right]),
      ]),
    ),
    #(
      "A",
      dict.from_list([
        #("7", [Up, Left, Left, Up, Up]),
        #("8", [Up, Left, Up, Up]),
        #("9", [Up, Up, Up]),
        #("4", [Up, Left, Left, Up]),
        #("5", [Up, Left, Up]),
        #("6", [Up, Up]),
        #("1", [Up, Left, Left]),
        #("2", [Up, Left]),
        #("3", [Up]),
        #("0", [Left]),
        #("A", []),
      ]),
    ),
  ])
}

// [A]

// ^

// [x, x, x, A, Left, A, A, Down, Left, A, A, Right, Right, Up, A, Down, A, A, Up, A, Down, Left, A, A, A, Right, Up, A]

// [Down, Left, Left, A, Right, Right, Up, A, A, Down, Left, A, Left, A, Right, Right, Up, A, A, Down, A, A, Up, Left, A, Right, A, Down, Left, A, Right, Up, A, A, Left, A, Right, A, Down, Left, A, Left, A, Right, Right, Up, A, A, A, Down, A, Up, Left, A, Right, A]

// <vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A

//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
pub fn directional_keyboard_path_dict() -> DirectionalPathDict {
  dict.from_list([
    #(
      Up,
      dict.from_list([
        #(Up, []),
        #(Down, [Down]),
        #(Left, [Down, Left]),
        #(Right, [Right, Down]),
        #(A, [Right]),
      ]),
    ),
    #(
      Down,
      dict.from_list([
        #(Up, [Up]),
        #(Down, []),
        #(Left, [Left]),
        #(Right, [Right]),
        #(A, [Right, Up]),
      ]),
    ),
    #(
      Left,
      dict.from_list([
        #(Up, [Right, Up]),
        #(Down, [Right]),
        #(Left, []),
        #(Right, [Right, Right]),
        #(A, [Right, Right, Up]),
      ]),
    ),
    #(
      Right,
      dict.from_list([
        #(Up, [Up, Left]),
        #(Down, [Left]),
        #(Left, [Left, Left]),
        #(Right, []),
        #(A, [Up]),
      ]),
    ),
    #(
      A,
      dict.from_list([
        #(Up, [Left]),
        #(Down, [Down, Left]),
        #(Left, [Down, Left, Left]),
        #(Right, [Down]),
        #(A, []),
      ]),
    ),
  ])
}
