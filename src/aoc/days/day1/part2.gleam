import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day1/input.txt")

  let #(list1, list2) = parse_input(input)
  let list2_frequencies = frequencies(list2)

  list1
  |> list.map(fn(num) {
    let count = dict.get(list2_frequencies, num) |> result.unwrap(0)
    num * count
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string()
}

fn parse_input(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [num1, num2] = string.split(line, "   ")
    let num1 = result.unwrap(int.parse(num1), 0)
    let num2 = result.unwrap(int.parse(num2), 0)
    #(num1, num2)
  })
  |> list.unzip()
}

fn frequencies(list: List(Int)) {
  list.fold(list, dict.new(), fn(frequencies, num) {
    dict.upsert(frequencies, num, fn(count) {
      case count {
        Some(i) -> i + 1
        None -> 1
      }
    })
  })
}
