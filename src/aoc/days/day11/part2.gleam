import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day11/input.txt")

  input
  |> parse_input
  |> blink_many(75)
  |> dict.to_list()
  |> list.map(fn(stone) -> Int { stone.1 })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn blink_many(stones: Dict(Int, Int), times: Int) -> Dict(Int, Int) {
  list.range(1, times)
  |> list.fold(stones, fn(stones, _) { blink(stones) })
}

fn blink(stones: Dict(Int, Int)) -> Dict(Int, Int) {
  stones
  |> dict.fold(from: dict.new(), with: fn(new_stones, stone, count) {
    case stone {
      0 -> add(new_stones, 1, count)
      _ ->
        case has_even_digits(stone) {
          True -> {
            let #(a, b) = split_num(stone)
            new_stones
            |> add(a, count)
            |> add(b, count)
          }
          False -> add(new_stones, stone * 2024, count)
        }
    }
  })
}

fn add(stones: Dict(Int, Int), stone: Int, count: Int) -> Dict(Int, Int) {
  dict.upsert(stones, stone, fn(x) {
    case x {
      Some(i) -> i + count
      None -> count
    }
  })
}

fn parse_input(input: String) -> Dict(Int, Int) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(fn(str) { #(to_int(str), 1) })
  |> dict.from_list
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
