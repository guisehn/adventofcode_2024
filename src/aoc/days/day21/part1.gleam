import gleam/dict
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

import aoc/days/day21/directions.{
  type DirectionButton, type DirectionalPathDict, type NumericPathDict, A,
  directional_keyboard_path_dict, numeric_keypad_path_dict,
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day21/input.txt")
  let codes = input |> string.trim |> string.split("\n")

  let numeric_keypad_path_dict = numeric_keypad_path_dict()
  let direction_keypad_path_dict = directional_keyboard_path_dict()

  codes
  |> list.map(fn(code) {
    let assert Ok(min_button_presses) =
      code
      |> directional_to_numeric_keypad(numeric_keypad_path_dict)
      |> list.map(fn(possibilities) {
        possibilities
        |> directional_to_directional_keypad(direction_keypad_path_dict)
        |> directional_to_directional_keypad(direction_keypad_path_dict)
        |> list.length
      })
      |> list.sort(by: int.compare)
      |> list.first

    min_button_presses * get_code_numeric_path(code)
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

pub fn directional_to_numeric_keypad(code: String, path_dict: NumericPathDict) {
  // let k: #(String, List(List(DirectionButton))) = #("A", [])

  let #(_, paths) =
    code
    |> string.split("")
    |> list.fold(from: #("A", [[]]), with: fn(acc, current_digit) {
      let #(prev_digit, prev_paths) = acc

      let assert Ok(next_paths) = dict.get(path_dict, prev_digit)
      let assert Ok(next_paths) = dict.get(next_paths, current_digit)

      let next_paths =
        list.map(next_paths, fn(path) { list.flatten([path, [A]]) })

      let new_paths =
        list.flat_map(prev_paths, fn(prev_path) {
          list.map(next_paths, fn(path) { list.flatten([prev_path, path]) })
        })

      #(current_digit, new_paths)
    })

  paths
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
