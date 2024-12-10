import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day3/input.txt")
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")

  regexp.scan(re, input)
  |> list.map(fn(match) {
    case match.submatches {
      [Some(a), Some(b)] -> {
        let a = result.unwrap(int.parse(a), 0)
        let b = result.unwrap(int.parse(b), 0)
        a * b
      }

      _ -> 0
    }
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}
