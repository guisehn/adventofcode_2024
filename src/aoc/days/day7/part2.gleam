import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Equation {
  IncompleteEquation(result: Int, numbers: List(Int))
}

type CalculationItem {
  Number(Int)
  Operator(String)
}

type Calculation =
  List(CalculationItem)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day7/input.txt")
  let equations = parse_input(input)

  equations
  |> list.filter(fn(equation) {
    equation.numbers
    |> permutate_calculations
    |> list.any(fn(calculation) {
      execute_calculation(calculation) == equation.result
    })
  })
  |> list.map(fn(equation) { equation.result })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [result, numbers] = string.split(line, ": ")
    IncompleteEquation(
      result: to_int(result),
      numbers: numbers |> string.split(" ") |> list.map(to_int),
    )
  })
}

fn permutate_calculations(numbers: List(Int)) -> List(Calculation) {
  let permutations = permutate_operators(list.length(numbers) - 1)
  let numbers = list.map(numbers, fn(n) { Number(n) })

  list.map(permutations, fn(operators) {
    list.transpose([numbers, operators]) |> list.flatten()
  })
}

fn permutate_operators(amount: Int) {
  list.range(0, pow(3, amount) - 1)
  |> list.map(fn(n) {
    n
    |> int.to_base_string(3)
    |> result.unwrap("")
    |> string.replace("0", "+")
    |> string.replace("1", "*")
    |> string.replace("2", "|")
    |> string.pad_start(to: amount, with: "+")
    |> string.split("")
    |> list.map(fn(o) { Operator(o) })
  })
}

fn execute_calculation(calculation: Calculation) {
  case calculation {
    [Number(a), Operator("+"), Number(b), ..rest] ->
      execute_calculation([Number(a + b), ..rest])

    [Number(a), Operator("*"), Number(b), ..rest] ->
      execute_calculation([Number(a * b), ..rest])

    [Number(a), Operator("|"), Number(b), ..rest] ->
      execute_calculation([
        Number(to_int(int.to_string(a) <> int.to_string(b))),
        ..rest
      ])

    [Number(result)] -> result

    _ -> panic as { "Invalid calculation: " <> string.inspect(calculation) }
  }
}

fn pow(base: Int, exponent: Int) {
  int.power(base, int.to_float(exponent))
  |> result.unwrap(0.0)
  |> float.truncate
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
