import aoc/days/day17/part1.{
  CPU, adv, bdv, bst, bxc, bxl, cdv, get_register, jnz, set_register, to_program,
}
import gleam/dict
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn adv_test() {
  let cpu =
    CPU(
      program: dict.new(),
      registers: dict.from_list([#("A", 107), #("B", 6), #("C", 3)]),
      pointer: 0,
      output: [],
    )

  // 107 / (2 ^ 2) = 26
  let literal_operand = 2
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(adv(cpu) |> get_register("A"), 26)

  // 107 / (2 ^ 6) = 4
  let combo_operand = 5
  let cpu = CPU(..cpu, program: to_program([0, combo_operand]))
  should.equal(adv(cpu) |> get_register("A"), 1)

  // jumps pointer by 2
  should.equal(adv(cpu).pointer, 2)
}

pub fn bxl_test() {
  let cpu =
    CPU(
      program: dict.new(),
      registers: dict.from_list([#("A", 107), #("B", 10), #("C", 3)]),
      pointer: 0,
      output: [],
    )

  // 10 xor 3 = 9
  let literal_operand = 3
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(bxl(cpu) |> get_register("B"), 9)

  // 10 xor 5 = 15
  let literal_operand = 5
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(bxl(cpu) |> get_register("B"), 15)

  // jumps pointer by 2
  should.equal(bxl(cpu).pointer, 2)
}

pub fn bst_test() {
  let cpu =
    CPU(
      program: dict.new(),
      registers: dict.from_list([#("A", 100), #("B", 10), #("C", 3)]),
      pointer: 0,
      output: [],
    )

  // 2 % 8 = 2
  let literal_operand = 2
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(bst(cpu) |> get_register("B"), 2)

  // 100 % 8 = 4
  let combo_operand = 4
  let cpu = CPU(..cpu, program: to_program([0, combo_operand]))
  should.equal(bst(cpu) |> get_register("B"), 4)

  // jumps pointer by 2
  should.equal(bst(cpu).pointer, 2)
}

pub fn jnz_test() {
  let cpu =
    CPU(program: dict.new(), registers: dict.new(), pointer: 0, output: [])

  // jumps pointer by 2 if A is 0
  let cpu = set_register(cpu, "A", 0)
  should.equal(jnz(cpu).pointer, 2)

  // goes to operand if A is not 0
  let literal_operand = 5
  let cpu =
    CPU(..cpu, program: to_program([0, literal_operand, 1, 1, 1, 1, 1, 1, 1]))
    |> set_register("A", 1)
  should.equal(jnz(cpu).pointer, literal_operand)
}

pub fn bxc_test() {
  let cpu =
    CPU(program: dict.new(), registers: dict.new(), pointer: 0, output: [])

  // 10 xor 3 = 9
  let cpu = cpu |> set_register("B", 10) |> set_register("C", 3)
  should.equal(bxc(cpu) |> get_register("B"), 9)

  // 10 xor 5 = 15
  let cpu = cpu |> set_register("B", 10) |> set_register("C", 5)
  should.equal(bxc(cpu) |> get_register("B"), 15)

  // jumps pointer by 2
  should.equal(bxc(cpu).pointer, 2)
}

pub fn bdv_test() {
  let cpu =
    CPU(
      program: dict.new(),
      registers: dict.from_list([#("A", 107), #("B", 6), #("C", 3)]),
      pointer: 0,
      output: [],
    )

  // 107 / (2 ^ 2) = 26
  let literal_operand = 2
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(bdv(cpu) |> get_register("B"), 26)

  // 107 / (2 ^ 6) = 4
  let combo_operand = 5
  let cpu = CPU(..cpu, program: to_program([0, combo_operand]))
  should.equal(bdv(cpu) |> get_register("B"), 1)

  // jumps pointer by 2
  should.equal(bdv(cpu).pointer, 2)
}

pub fn cdv_test() {
  let cpu =
    CPU(
      program: dict.new(),
      registers: dict.from_list([#("A", 107), #("B", 6), #("C", 3)]),
      pointer: 0,
      output: [],
    )

  // 107 / (2 ^ 2) = 26
  let literal_operand = 2
  let cpu = CPU(..cpu, program: to_program([0, literal_operand]))
  should.equal(cdv(cpu) |> get_register("C"), 26)

  // 107 / (2 ^ 6) = 4
  let combo_operand = 5
  let cpu = CPU(..cpu, program: to_program([0, combo_operand]))
  should.equal(cdv(cpu) |> get_register("C"), 1)

  // jumps pointer by 2
  should.equal(cdv(cpu).pointer, 2)
}
