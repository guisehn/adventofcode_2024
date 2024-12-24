import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Operation {
  Operation(a: String, op: Operator, b: String, output: String)
}

type Registers =
  Dict(String, Int)

type Operator {
  AND
  OR
  XOR
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day24/input.txt")

  let #(registers, operations) = parse_input(input)

  let assert Ok(result) =
    calc_all_operations(registers, operations)
    |> calc_final_result

  int.to_string(result)
}

fn calc_final_result(registers: Registers) {
  registers
  |> dict.filter(fn(k, _) { string.starts_with(k, "z") })
  |> dict.to_list
  |> list.map(fn(item) {
    let assert #("z" <> k, v) = item
    let z = to_int(k)
    #(z, v)
  })
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(item) { item.1 })
  |> list.reverse
  |> int.undigits(2)
}

fn calc_all_operations(registers: Registers, operations: List(Operation)) {
  let operations_dict =
    operations
    |> list.fold(from: dict.new(), with: fn(acc, op) {
      acc
      |> dict.upsert(op.a, fn(cur) {
        cur |> option.unwrap(set.new()) |> set.insert(op)
      })
      |> dict.upsert(op.b, fn(cur) {
        cur |> option.unwrap(set.new()) |> set.insert(op)
      })
    })

  let queue =
    operations
    |> list.filter(fn(op) { can_be_calculated(op, registers) })
    |> deque.from_list

  calc_all_operations_loop(queue, operations_dict, registers)
}

fn calc_all_operations_loop(
  queue: Deque(Operation),
  operations_dict: Dict(String, Set(Operation)),
  registers: Registers,
) {
  case deque.pop_front(queue) {
    Error(_) -> registers

    Ok(#(op, queue)) -> {
      let registers = calc_operation(op, registers)

      let next_ops =
        operations_dict
        |> dict.get(op.output)
        |> result.unwrap(set.new())
        |> set.filter(fn(op) { can_be_calculated(op, registers) })

      let queue = set.fold(next_ops, from: queue, with: deque.push_back)

      calc_all_operations_loop(queue, operations_dict, registers)
    }
  }
}

fn can_be_calculated(op: Operation, registers: Registers) -> Bool {
  case dict.get(registers, op.a), dict.get(registers, op.b) {
    Ok(_), Ok(_) -> True
    _, _ -> False
  }
}

fn calc_operation(operation: Operation, registers: Registers) -> Registers {
  let Operation(a:, op:, b:, output:) = operation
  let assert Ok(a) = dict.get(registers, a)
  let assert Ok(b) = dict.get(registers, b)

  let result = case op {
    AND -> int.bitwise_and(a, b)
    OR -> int.bitwise_or(a, b)
    XOR -> int.bitwise_exclusive_or(a, b)
  }

  dict.insert(registers, output, result)
}

fn parse_input(input: String) -> #(Registers, List(Operation)) {
  let assert [registers, operations] =
    input
    |> string.trim
    |> string.split("\n\n")

  let registers =
    registers
    |> string.split("\n")
    |> list.fold(from: dict.new(), with: fn(acc, line) {
      let assert [var, value] = string.split(line, ": ")
      dict.insert(acc, var, to_int(value))
    })

  let assert Ok(re) = regexp.from_string("(.+) (AND|OR|XOR) (.+) -> (.+)")

  let operations =
    operations
    |> string.split("\n")
    |> list.map(fn(op) {
      let assert [
        Match(
          submatches: [Some(a), Some(op), Some(b), Some(output)],
          ..,
        ),
      ] = regexp.scan(re, op)

      let op = case op {
        "AND" -> AND
        "OR" -> OR
        "XOR" -> XOR
        _ -> panic as { "unknown op " <> op }
      }

      Operation(a:, op:, b:, output:)
    })

  #(registers, operations)
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
