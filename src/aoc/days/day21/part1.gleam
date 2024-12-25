import aoc/days/day21/directions.{
  type DirectionButton, type DirectionalPathDict, type NumericPathDict, A,
  directional_keyboard_path_dict, numeric_keypad_path_dict,
}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day21/input.txt")
  let codes = input |> string.trim |> string.split("\n")

  let numeric_keypad_path_dict = numeric_keypad_path_dict()
  let direction_keypad_path_dict = directional_keyboard_path_dict()

  codes
  |> list.map(fn(code) {
    io.println(code)

    let button_presses =
      code
      |> directional_to_numeric_keypad(numeric_keypad_path_dict)
      |> debug
      |> directional_to_directional_keypad(direction_keypad_path_dict)
      |> debug
      |> directional_to_directional_keypad(direction_keypad_path_dict)
      |> debug
      |> list.length

    io.println(
      string.inspect(button_presses)
      <> " * "
      <> string.inspect(get_code_numeric_path(code)),
    )

    io.println("====================================")

    button_presses * get_code_numeric_path(code)
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn debug(l: List(_)) {
  io.println(string.inspect(list.length(l)) <> " - " <> string.inspect(l))
  io.println("--------------------")
  l
}

pub fn directional_to_numeric_keypad(
  code: String,
  path_dict: NumericPathDict,
) -> List(DirectionButton) {
  let #(_, path) =
    code
    |> string.split("")
    |> list.fold(from: #("A", []), with: fn(acc, current_digit) {
      let #(prev_digit, prev_directions) = acc

      // io.println(
      //   "looking for " <> current_digit <> ", previous digit " <> prev_digit,
      // )

      let assert Ok(paths) = dict.get(path_dict, prev_digit)
      let assert Ok(path) = dict.get(paths, current_digit)
      let path = list.flatten([path, [A]])

      #(current_digit, [path, ..prev_directions])
    })

  path |> list.reverse |> list.flatten
}

pub fn directional_to_directional_keypad(
  presses: List(DirectionButton),
  path_dict: DirectionalPathDict,
) {
  let #(_, path) =
    presses
    |> list.fold(from: #(A, []), with: fn(acc, current_button) {
      let #(prev_button, prev_presses) = acc

      let assert Ok(paths) = dict.get(path_dict, prev_button)
      let assert Ok(path) = dict.get(paths, current_button)
      let path = list.flatten([path, [A]])

      #(current_button, [path, ..prev_presses])
    })

  path |> list.reverse |> list.flatten
}

fn get_code_numeric_path(code: String) -> Int {
  let assert Ok(re) = regexp.from_string("[^0-9]")
  regexp.replace(re, code, "") |> int.parse |> result.unwrap(0)
}
