import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/option.{Some}
import gleam/otp/task.{type Task}
import gleam/regexp.{Match}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Robot {
  Robot(pos: Coord, velocity: Coord)
}

const width = 101

const height = 103

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day14/input.txt")
  let robots = parse_input(input)

  let #(iterations, xmas_tree) =
    list.range(1, 10_000)
    |> list.fold_until(#(0, robots), fn(acc, _) {
      let #(i, robots) = acc
      let robots = move_all(robots)
      let coord_set = to_coord_set(robots)
      let largest_line = find_largest_vertical_line(coord_set)

      case largest_line > 10 {
        True -> Stop(#(i + 1, robots))
        False -> Continue(#(i + 1, robots))
      }
    })

  xmas_tree |> to_coord_set |> print_map

  int.to_string(iterations)
}

fn move_all(robot: List(Robot)) {
  robot
  |> list.map(fn(robot) { task.async(fn() { move(robot) }) })
  |> await_all_tasks
}

fn move(robot: Robot) {
  let new_pos = #(
    mod(robot.pos.0 + robot.velocity.0, width),
    mod(robot.pos.1 + robot.velocity.1, height),
  )
  Robot(new_pos, robot.velocity)
}

fn to_coord_set(robots: List(Robot)) {
  robots
  |> list.map(fn(robot) { robot.pos })
  |> set.from_list
}

fn find_largest_vertical_line(robot_coords: Set(Coord)) {
  let #(_visited, largest_line_length) =
    robot_coords
    |> set.to_list
    |> list.fold(#(set.new(), 0), fn(acc, coord) {
      let #(visited, largest_line_length) = acc
      case set.contains(visited, coord) {
        True -> acc
        False -> {
          let #(line_length, visited) =
            find_vertical_line_length(coord, robot_coords, visited, 1)
          case line_length > largest_line_length {
            True -> #(visited, line_length)
            False -> #(visited, largest_line_length)
          }
        }
      }
    })

  largest_line_length
}

fn find_vertical_line_length(
  coord: Coord,
  coords: Set(Coord),
  visited: Set(Coord),
  length_acc: Int,
) {
  let #(x, y) = coord
  let next_coord = #(x, y + 1)
  let visited = set.insert(visited, coord)

  case set.contains(coords, next_coord) {
    True ->
      find_vertical_line_length(next_coord, coords, visited, length_acc + 1)
    False -> #(length_acc, visited)
  }
}

fn print_map(robot_coords: Set(Coord)) {
  list.range(0, height - 1)
  |> list.each(fn(y) {
    list.range(0, width - 1)
    |> list.each(fn(x) {
      let char = case set.contains(robot_coords, #(x, y)) {
        True -> "#"
        False -> "."
      }
      io.print(char)
    })
    io.print("\n")
  })
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
