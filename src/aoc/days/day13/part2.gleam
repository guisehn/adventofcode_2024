import gleam/float
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import simplifile

type Machine {
  Machine(
    button_a: #(Float, Float),
    button_b: #(Float, Float),
    prize: #(Float, Float),
  )
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day13/input.txt")
  let machines = parse_input(input)

  machines
  |> list.map(find_optimal_tokens)
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn find_optimal_tokens(machine: Machine) {
  let #(ax, ay) = machine.button_a
  let #(bx, by) = machine.button_b
  let #(px, py) = machine.prize

  // thanks https://www.youtube.com/watch?v=-5J-DAsWuJc&t=236s for the math
  let a_presses = { px *. by -. py *. bx } /. { ax *. by -. ay *. bx }
  let b_presses = { px -. ax *. a_presses } /. bx

  case
    a_presses == float.floor(a_presses) && b_presses == float.floor(b_presses)
  {
    True -> calc_tokens(float.round(a_presses), float.round(b_presses))
    False -> 0
  }
}

fn calc_tokens(a_presses: Int, b_presses: Int) {
  a_presses * 3 + b_presses
}

fn parse_input(input: String) -> List(Machine) {
  let assert Ok(re_button_a) =
    regexp.from_string("Button A: X\\+([0-9]+), Y\\+([0-9]+)")
  let assert Ok(re_button_b) =
    regexp.from_string("Button B: X\\+([0-9]+), Y\\+([0-9]+)")
  let assert Ok(re_prize) = regexp.from_string("Prize: X=([0-9]+), Y=([0-9]+)")

  input
  |> string.split("\n\n")
  |> list.map(fn(machine) {
    let assert [Match(submatches: [Some(ax), Some(ay)], ..)] =
      regexp.scan(re_button_a, machine)
    let assert [Match(submatches: [Some(bx), Some(by)], ..)] =
      regexp.scan(re_button_b, machine)
    let assert [Match(submatches: [Some(px), Some(py)], ..)] =
      regexp.scan(re_prize, machine)
    Machine(
      button_a: #(to_float(ax), to_float(ay)),
      button_b: #(to_float(bx), to_float(by)),
      prize: #(
        to_float(px) +. 10_000_000_000_000.0,
        to_float(py) +. 10_000_000_000_000.0,
      ),
    )
  })
}

fn to_float(str: String) {
  result.unwrap(float.parse(str <> ".0"), 0.0)
}
