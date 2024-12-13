import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day11/input.txt")

  input
  |> parse_input
  |> blink_many(75)
  |> list.length
  |> int.to_string
}

fn blink_many(stones: List(Int), times: Int) -> List(Int) {
  list.range(1, times)
  |> list.fold(stones, fn(stones, _) { blink(stones) })
}

fn blink(stones: List(Int)) -> List(Int) {
  stones
  |> list.fold(from: [], with: fn(new_stones, stone) {
    case stone {
      0 -> [1, ..new_stones]
      _ ->
        case has_even_digits(stone) {
          True -> {
            let #(a, b) = split_num(stone)
            [b, a, ..new_stones]
          }
          False -> [stone * 2024, ..new_stones]
        }
    }
  })
  |> list.reverse()
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(to_int)
}

fn has_even_digits(n: Int) {
  { float.truncate(log10(n)) + 1 } % 2 == 0
}

fn split_num(num: Int) {
  let str = int.to_string(num)
  let len = string.length(str)
  let part1 = string.slice(str, 0, len / 2)
  let part2 = string.slice(str, len / 2, len)
  #(to_int(part1), to_int(part2))
}

fn to_int(str: String) {
  result.unwrap(int.parse(str), 0)
}

@external(erlang, "math", "log10")
fn log10(n: Int) -> Float
