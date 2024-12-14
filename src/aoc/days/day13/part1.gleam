import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import simplifile

type Machine {
  Machine(button_a: #(Int, Int), button_b: #(Int, Int), prize: #(Int, Int))
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
  list.range(0, 100)
  |> list.fold([], fn(results, a_presses) {
    list.range(0, 100)
    |> list.fold(results, fn(results, b_presses) {
      let x = machine.button_a.0 * a_presses + machine.button_b.0 * b_presses
      let y = machine.button_a.1 * a_presses + machine.button_b.1 * b_presses
      case x == machine.prize.0 && y == machine.prize.1 {
        True -> [#(a_presses, b_presses), ..results]
        False -> results
      }
    })
  })
  |> list.map(calc_tokens)
  |> list.sort(by: int.compare)
  |> list.first
  |> result.unwrap(0)
}

fn calc_tokens(presses: #(Int, Int)) {
  let #(a_presses, b_presses) = presses
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
      button_a: #(to_int(ax), to_int(ay)),
      button_b: #(to_int(bx), to_int(by)),
      prize: #(to_int(px), to_int(py)),
    )
  })
}

fn to_int(str: String) {
  result.unwrap(int.parse(str), 0)
}
