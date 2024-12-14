import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/otp/task.{type Task}
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Robot {
  Robot(pos: Coord, velocity: Coord)
}

type Quadrant {
  Quadrant(top_left: Coord, bottom_right: Coord)
}

const width = 101

const height = 103

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day14/input.txt")

  input
  |> parse_input
  |> list.map(fn(robot) { task.async(fn() { move_times(robot, 100) }) })
  |> await_all_tasks
  |> group_by_quadrant(build_quadrants())
  |> calc_safety_factor
  |> int.to_string
}

fn move_times(robot: Robot, times: Int) {
  list.range(1, times)
  |> list.fold(robot, fn(robot, _) { move(robot) })
}

fn move(robot: Robot) {
  let new_pos = #(
    mod(robot.pos.0 + robot.velocity.0, width),
    mod(robot.pos.1 + robot.velocity.1, height),
  )
  Robot(new_pos, robot.velocity)
}

fn group_by_quadrant(robots: List(Robot), quadrants: List(Quadrant)) {
  list.map(quadrants, fn(quadrant) {
    task.async(fn() {
      list.filter(robots, fn(robot) {
        robot.pos.0 >= quadrant.top_left.0
        && robot.pos.0 <= quadrant.bottom_right.0
        && robot.pos.1 >= quadrant.top_left.1
        && robot.pos.1 <= quadrant.bottom_right.1
      })
    })
  })
  |> await_all_tasks
}

fn calc_safety_factor(grouped_robots: List(List(Robot))) {
  grouped_robots
  |> list.map(fn(robots) { list.length(robots) })
  |> list.reduce(fn(a, b) { a * b })
  |> result.unwrap(0)
}

fn parse_input(input: String) -> List(Robot) {
  let assert Ok(re) =
    regexp.from_string("p=([-0-9]+),([-0-9]+) v=([-0-9]+),([-0-9]+)")

  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Match(submatches: [Some(x), Some(y), Some(vx), Some(vy)], ..)] =
      regexp.scan(re, line)
    Robot(pos: #(to_int(x), to_int(y)), velocity: #(to_int(vx), to_int(vy)))
  })
}

fn build_quadrants() {
  let middle_x = width / 2
  let middle_y = height / 2

  [
    // top left
    Quadrant(top_left: #(0, 0), bottom_right: #(middle_x - 1, middle_y - 1)),
    // top right
    Quadrant(top_left: #(middle_x + 1, 0), bottom_right: #(
      width - 1,
      middle_y - 1,
    )),
    // bottom left
    Quadrant(top_left: #(0, middle_y + 1), bottom_right: #(
      middle_x - 1,
      height - 1,
    )),
    // bottom right
    Quadrant(top_left: #(middle_x + 1, middle_y + 1), bottom_right: #(
      width - 1,
      height - 1,
    )),
  ]
}

fn to_int(str: String) {
  result.unwrap(int.parse(str), 0)
}

fn mod(a: Int, b: Int) {
  { { a % b } + b } % b
}

const task_timeout = 5000

fn await_all_tasks(tasks: List(Task(x))) {
  tasks
  |> task.try_await_all(task_timeout)
  |> list.map(fn(result) {
    let assert Ok(result) = result
    result
  })
}
