import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day1/input.txt")

  let #(list1, list2) = parse_input(input)
  let list1 = list.sort(list1, by: int.compare)
  let list2 = list.sort(list2, by: int.compare)

  list.map2(list1, list2, fn(num1, num2) { int.absolute_value(num1 - num2) })
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
