import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day22/input.txt")
  let numbers = input |> string.trim |> string.split("\n") |> list.map(to_int)

  numbers
  |> list.map(fn(n) { next_n_secret(n, 2000) })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn next_n_secret(secret: Int, n: Int) {
  list.range(1, n)
  |> list.fold(secret, fn(secret, _) { next_secret(secret) })
}

fn next_secret(secret: Int) {
  let step1 = { secret * 64 } |> mix(secret) |> prune
  let step2 = { step1 / 32 } |> mix(step1)
  let step3 = step2 * 2048 |> mix(step2) |> prune
  step3
}

fn mix(a: Int, b: Int) {
  int.bitwise_exclusive_or(a, b)
}

fn prune(n: Int) {
  let assert Ok(result) = int.modulo(n, 16_777_216)
  result
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
