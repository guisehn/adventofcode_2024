import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Direction {
  Up
  Down
  Left
  Right
}

type Map =
  Dict(Coord, String)

type State {
  State(map: Map, coord: Coord, direction: Direction, visited: Set(Coord))
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day6/input.txt")

  let initial_state = parse_input(input)
  let final_state = walk(initial_state)

  int.to_string(set.size(final_state.visited))
}

fn parse_input(input: String) {
  let coord_list =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(row, y) {
      let cols = string.split(row, "")
      list.index_map(cols, fn(value, x) { #(#(x, y), value) })
    })
    |> list.flatten()

  let map = dict.from_list(coord_list)

  let assert Ok(#(coord, _)) =
    coord_list
    |> list.find(fn(item) {
      let #(_, char) = item
      char == "^"
    })

  let visited = set.new() |> set.insert(coord)

  State(map:, coord:, visited:, direction: Up)
}

fn walk(state: State) -> State {
  let #(x, y) = state.coord

  let next_coord = case state.direction {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }

  case dict.get(state.map, next_coord) {
    Ok("#") -> {
      let next_direction = rotate(state.direction)
      let next_state = State(..state, direction: next_direction)
      walk(next_state)
    }

    Ok(_) -> {
      let next_state =
        State(
          ..state,
          coord: next_coord,
          visited: set.insert(state.visited, next_coord),
        )
      walk(next_state)
    }

    Error(_) -> state
  }
}

fn rotate(direction: Direction) {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}
