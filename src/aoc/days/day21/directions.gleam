import gleam/dict.{type Dict}
import gleam/list
import gleam/set

pub type DirectionButton {
  Up
  Down
  Left
  Right
  A
}

pub type NumericPathDict =
  Dict(String, Dict(String, List(List(DirectionButton))))

pub type DirectionalPathDict =
  Dict(DirectionButton, Dict(DirectionButton, List(DirectionButton)))

fn permutations(list: List(_)) {
  list
  |> list.permutations
  |> list.unique
}

fn except(list: List(_), except: List(_)) {
  set.from_list(list)
  |> set.difference(set.from_list(except))
  |> set.to_list
}

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
        #("7", permutations([])),
        #("8", permutations([Right])),
        #("9", permutations([Right, Right])),
        #("4", permutations([Down])),
        #("5", permutations([Right, Down])),
        #("6", permutations([Right, Right, Down])),
        #("1", permutations([Down, Down])),
        #("2", permutations([Right, Down, Down])),
        #("3", permutations([Right, Right, Down, Down])),
        #(
          "0",
          permutations([Right, Down, Down, Down])
            |> except([[Down, Down, Down, Right]]),
        ),
        #(
          "A",
          permutations([Right, Right, Down, Down, Down])
            |> except([[Down, Down, Down, Right, Right]]),
        ),
      ]),
    ),
    #(
      "8",
      dict.from_list([
        #("7", permutations([Left])),
        #("8", permutations([])),
        #("9", permutations([Right])),
        #("4", permutations([Down, Left])),
        #("5", permutations([Down])),
        #("6", permutations([Right, Down])),
        #("1", permutations([Down, Down, Left])),
        #("2", permutations([Down, Down])),
        #("3", permutations([Right, Down, Down])),
        #("0", permutations([Down, Down, Down])),
        #("A", permutations([Right, Down, Down, Down])),
      ]),
    ),
    #(
      "9",
      dict.from_list([
        #("7", permutations([Left, Left])),
        #("8", permutations([Left])),
        #("9", permutations([])),
        #("4", permutations([Down, Left, Left])),
        #("5", permutations([Down, Left])),
        #("6", permutations([Down])),
        #("1", permutations([Down, Down, Left, Left])),
        #("2", permutations([Down, Down, Left])),
        #("3", permutations([Down, Down])),
        #("0", permutations([Down, Down, Down, Left])),
        #("A", permutations([Down, Down, Down])),
      ]),
    ),
    #(
      "4",
      dict.from_list([
        #("7", permutations([Up])),
        #("8", permutations([Up, Right])),
        #("9", permutations([Up, Right, Right])),
        #("4", permutations([])),
        #("5", permutations([Right])),
        #("6", permutations([Right, Right])),
        #("1", permutations([Down])),
        #("2", permutations([Right, Down])),
        #("3", permutations([Right, Right, Down])),
        #(
          "0",
          permutations([Right, Down, Down])
            |> except([[Down, Down, Right]]),
        ),
        #(
          "A",
          permutations([Right, Right, Down, Down])
            |> except([[Down, Down, Right, Right]]),
        ),
      ]),
    ),
    #(
      "5",
      dict.from_list([
        #("7", permutations([Up, Left])),
        #("8", permutations([Up])),
        #("9", permutations([Up, Right])),
        #("4", permutations([Left])),
        #("5", permutations([])),
        #("6", permutations([Right])),
        #("1", permutations([Down, Left])),
        #("2", permutations([Down])),
        #("3", permutations([Right, Down])),
        #("0", permutations([Down, Down])),
        #("A", permutations([Right, Down, Down])),
      ]),
    ),
    #(
      "6",
      dict.from_list([
        #("7", permutations([Up, Left, Left])),
        #("8", permutations([Up, Left])),
        #("9", permutations([Up])),
        #("4", permutations([Left, Left])),
        #("5", permutations([Left])),
        #("6", permutations([])),
        #("1", permutations([Down, Left, Left])),
        #("2", permutations([Down, Left])),
        #("3", permutations([Down])),
        #("0", permutations([Down, Down, Left])),
        #("A", permutations([Down, Down])),
      ]),
    ),
    #(
      "1",
      dict.from_list([
        #("7", permutations([Up, Up])),
        #("8", permutations([Up, Up, Right])),
        #("9", permutations([Up, Up, Right, Right])),
        #("4", permutations([Up])),
        #("5", permutations([Up, Right])),
        #("6", permutations([Up, Right, Right])),
        #("1", permutations([])),
        #("2", permutations([Right])),
        #("3", permutations([Right, Right])),
        #("0", [[Right, Down]]),
        #(
          "A",
          permutations([Right, Right, Down])
            |> except([[Down, Right, Right]]),
        ),
      ]),
    ),
    #(
      "2",
      dict.from_list([
        #("7", permutations([Up, Up, Left])),
        #("8", permutations([Up, Up])),
        #("9", permutations([Up, Up, Right])),
        #("4", permutations([Up, Left])),
        #("5", permutations([Up])),
        #("6", permutations([Up, Right])),
        #("1", permutations([Left])),
        #("2", permutations([])),
        #("3", permutations([Right])),
        #("0", permutations([Down])),
        #("A", permutations([Right, Down])),
      ]),
    ),
    #(
      "3",
      dict.from_list([
        #("7", permutations([Left, Left, Up, Up])),
        #("8", permutations([Left, Up, Up])),
        #("9", permutations([Up, Up])),
        #("4", permutations([Left, Left, Up])),
        #("5", permutations([Left, Up])),
        #("6", permutations([Up])),
        #("1", permutations([Left, Left])),
        #("2", permutations([Left])),
        #("3", permutations([])),
        #("0", permutations([Down, Left])),
        #("A", permutations([Down])),
      ]),
    ),
    #(
      "0",
      dict.from_list([
        #("7", permutations([Up, Up, Up, Left]) |> except([[Left, Up, Up, Up]])),
        #("8", permutations([Up, Up, Up])),
        #("9", permutations([Up, Up, Up, Right])),
        #("4", permutations([Up, Up, Left]) |> except([[Left, Up, Up]])),
        #("5", permutations([Up, Up])),
        #("6", permutations([Up, Up, Right])),
        #("1", [[Up, Left]]),
        #("2", permutations([Up])),
        #("3", permutations([Up, Right])),
        #("0", permutations([])),
        #("A", permutations([Right])),
      ]),
    ),
    // +---+---+---+
    // | 7 | 8 | 9 |
    // +---+---+---+
    // | 4 | 5 | 6 |
    // +---+---+---+
    // | 1 | 2 | 3 |
    // +---+---+---+
    //     | 0 | A |
    //     +---+---+
    #(
      "A",
      dict.from_list([
        #(
          "7",
          permutations([Up, Up, Up, Left, Left])
            |> except([[Left, Left, Up, Up, Up]]),
        ),
        #("8", permutations([Up, Up, Up, Left])),
        #("9", permutations([Up, Up, Up])),
        #(
          "4",
          permutations([Up, Left, Left, Up])
            |> except([[Left, Left, Up, Up]]),
        ),
        #("5", permutations([Up, Left, Up])),
        #("6", permutations([Up, Up])),
        #("1", permutations([Up, Left, Left]) |> except([[Left, Left, Up]])),
        #("2", permutations([Up, Left])),
        #("3", permutations([Up])),
        #("0", permutations([Left])),
        #("A", permutations([])),
      ]),
    ),
  ])
}

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
