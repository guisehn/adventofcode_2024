import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type CPU {
  CPU(
    program: Dict(Int, Int),
    registers: Dict(String, Int),
    pointer: Int,
    output: List(Int),
  )
}

pub fn solve() {
  // too lazy to parse today
  let cpu =
    CPU(
      program: to_program([2, 4, 1, 1, 7, 5, 1, 5, 4, 5, 0, 3, 5, 5, 3, 0]),
      registers: dict.from_list([#("A", 30_344_604), #("B", 0), #("C", 0)]),
      pointer: 0,
      output: [],
    )

  let cpu = run_program(cpu)

  cpu.output |> list.reverse |> list.map(int.to_string) |> string.join(",")
}

fn run_program(cpu: CPU) {
  case get_current_opcode(cpu) {
    Some(_) -> cpu |> tick |> run_program
    None -> cpu
  }
}

fn tick(cpu: CPU) {
  case get_current_opcode(cpu) {
    Some(0) -> adv(cpu)
    Some(1) -> bxl(cpu)
    Some(2) -> bst(cpu)
    Some(3) -> jnz(cpu)
    Some(4) -> bxc(cpu)
    Some(5) -> out(cpu)
    Some(6) -> bdv(cpu)
    Some(7) -> cdv(cpu)
    Some(opcode) -> panic as { "unknown opcode " <> int.to_string(opcode) }
    None -> panic as { "end of program" }
  }
}

fn get_current_opcode(cpu: CPU) -> Option(Int) {
  case dict.get(cpu.program, cpu.pointer) {
    Ok(opcode) -> Some(opcode)
    Error(_) -> None
  }
}

fn get_current_operand(cpu: CPU) -> Int {
  let assert Ok(operand) = dict.get(cpu.program, cpu.pointer + 1)
  operand
}

pub fn adv(cpu: CPU) -> CPU {
  dv(cpu, "A")
}

pub fn bxl(cpu: CPU) -> CPU {
  let literal_operand = get_current_operand(cpu)
  let b = get_register(cpu, "B")
  let result = int.bitwise_exclusive_or(b, literal_operand)

  CPU(..cpu, pointer: cpu.pointer + 2)
  |> set_register("B", result)
}

pub fn bst(cpu: CPU) -> CPU {
  let combo_operand = calc_combo_operand(cpu, get_current_operand(cpu))
  let result = combo_operand % 8

  CPU(..cpu, pointer: cpu.pointer + 2)
  |> set_register("B", result)
}

pub fn jnz(cpu: CPU) -> CPU {
  case get_register(cpu, "A") {
    0 -> CPU(..cpu, pointer: cpu.pointer + 2)
    _ -> {
      let literal_operand = get_current_operand(cpu)
      CPU(..cpu, pointer: literal_operand)
    }
  }
}

pub fn bxc(cpu: CPU) -> CPU {
  let b = get_register(cpu, "B")
  let c = get_register(cpu, "C")
  let result = int.bitwise_exclusive_or(b, c)

  CPU(..cpu, pointer: cpu.pointer + 2)
  |> set_register("B", result)
}

pub fn out(cpu: CPU) -> CPU {
  let combo_operand = calc_combo_operand(cpu, get_current_operand(cpu))
  let result = combo_operand % 8
  CPU(..cpu, pointer: cpu.pointer + 2, output: [result, ..cpu.output])
}

pub fn bdv(cpu: CPU) -> CPU {
  dv(cpu, "B")
}

pub fn cdv(cpu: CPU) -> CPU {
  dv(cpu, "C")
}

fn dv(cpu: CPU, output_register: String) -> CPU {
  let combo_operand = get_current_operand(cpu)
  let numerator = get_register(cpu, "A")
  let assert Ok(divisor) =
    int.power(2, int.to_float(calc_combo_operand(cpu, combo_operand)))
  let result = numerator / float.truncate(divisor)

  CPU(..cpu, pointer: cpu.pointer + 2)
  |> set_register(output_register, result)
}

fn calc_combo_operand(cpu: CPU, operand: Int) -> Int {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> get_register(cpu, "A")
    5 -> get_register(cpu, "B")
    6 -> get_register(cpu, "C")
    _ -> panic as { "unknown combo operand " <> string.inspect(operand) }
  }
}

pub fn get_register(cpu: CPU, register: String) {
  let assert Ok(value) = dict.get(cpu.registers, register)
  value
}

pub fn set_register(cpu: CPU, register: String, value: Int) -> CPU {
  CPU(..cpu, registers: dict.insert(cpu.registers, register, value))
}

pub fn to_program(items: List(Int)) {
  items
  |> list.index_map(fn(item, index) { #(index, item) })
  |> dict.from_list
}
