import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, String)

type Direction {
  Up
  Down
  Left
  Right
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day15/input.txt")

  let #(map, moves, robot_coord) =
    input
    |> parse_input

  let #(_, map) =
    moves
    |> list.fold(#(robot_coord, map), fn(acc, move_direction) {
      let #(robot_coord, map) = acc
      let #(moved, new_map) = attempt_move(map, robot_coord, move_direction)
      let robot_coord = case moved {
        True -> calc_next_coord(robot_coord, move_direction)
        False -> robot_coord
      }
      #(robot_coord, new_map)
    })

  print_map(map)

  map
  |> get_boxes_gps_coords
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn get_boxes_gps_coords(map: Map) {
  map
  |> dict.to_list
  |> list.filter(fn(item) { item.1 == "O" })
  |> list.map(fn(item) {
    let #(#(x, y), _) = item
    100 * y + x
  })
}

fn attempt_move(map: Map, coord: Coord, direction: Direction) -> #(Bool, Map) {
  let assert Ok(char) = dict.get(map, coord)

  case char {
    "." -> #(True, map)
    "#" -> #(False, map)
    "O" | "@" -> {
      let next_coord = calc_next_coord(coord, direction)
      case attempt_move(map, next_coord, direction) {
        #(True, new_map) -> {
          let new_map =
            new_map
            |> dict.insert(coord, ".")
            |> dict.insert(next_coord, char)
          #(True, new_map)
        }
        #(False, _) -> #(False, map)
      }
    }
    _ -> panic as { "unknown char " <> char }
  }
}

fn calc_next_coord(coord: Coord, direction: Direction) -> Coord {
  let #(x, y) = coord

  case direction {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }
}

fn parse_input(input: String) -> #(Dict(Coord, String), List(Direction), Coord) {
  let assert [map, moves] = string.split(input, "\n\n")

  let map =
    map
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.split("")
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten

  let moves =
    moves
    |> string.replace("\n", "")
    |> string.split("")
    |> list.map(fn(char) {
      case char {
        "^" -> Up
        "v" -> Down
        "<" -> Left
        ">" -> Right
        _ -> panic as { "invalid move " <> char }
      }
    })

  let assert Ok(robot) = list.find(map, fn(item) { item.1 == "@" })

  #(dict.from_list(map), moves, robot.0)
}

fn print_map(map: Map) {
  let max_x =
    dict.keys(map)
    |> list.map(fn(coord) { coord.0 })
    |> list.sort(by: int.compare)
    |> list.last
    |> result.unwrap(0)

  let max_y =
    dict.keys(map)
    |> list.map(fn(coord) { coord.1 })
    |> list.sort(by: int.compare)
    |> list.last
    |> result.unwrap(0)

  list.range(0, max_y)
  |> list.each(fn(y) {
    list.range(0, max_x)
    |> list.each(fn(x) {
      let assert Ok(char) = dict.get(map, #(x, y))
      io.print(char)
    })
    io.print("\n")
  })
}
