import gleam/dict.{type Dict}
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

type VisitedWithDirection =
  #(Coord, Direction)

type State {
  State(
    map: Map,
    start_coord: Coord,
    coord: Coord,
    direction: Direction,
    visited: Set(Coord),
    visited_with_direction: Set(VisitedWithDirection),
    possible_obstructions: Set(Coord),
    finished: Bool,
  )
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day6/input.txt")

  let initial_state = parse_input(input)
  let final_state = simulate(initial_state)

  final_state.possible_obstructions
  |> set.size
  |> string.inspect
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

  let assert Ok(#(start_coord, _)) =
    coord_list
    |> list.find(fn(item) {
      let #(_, char) = item
      char == "^"
    })

  let map = dict.insert(map, start_coord, ".")

  State(
    map:,
    start_coord:,
    coord: start_coord,
    direction: Up,
    visited: set.new() |> set.insert(start_coord),
    visited_with_direction: set.new() |> set.insert(#(start_coord, Up)),
    possible_obstructions: set.new(),
    finished: False,
  )
}

fn simulate(state: State) -> State {
  let next_coord = next_coord(state)

  let is_wall = dict.get(state.map, next_coord) == Ok("#")

  let is_visited = set.contains(state.visited, next_coord)

  let possible_obstructions = case !is_wall && !is_visited {
    True -> {
      let state_with_new_obstruction =
        State(..state, map: dict.insert(state.map, next_coord, "#"))
      case will_loop(state_with_new_obstruction) {
        True -> set.insert(state.possible_obstructions, next_coord)
        False -> state.possible_obstructions
      }
    }

    False -> state.possible_obstructions
  }

  let updated_state =
    State(..state, possible_obstructions:)
    |> walk()

  case updated_state.finished {
    True -> updated_state
    False -> simulate(updated_state)
  }
}

fn will_loop(state: State) {
  let updated_state = walk(state)

  case updated_state.finished {
    True -> False

    False -> {
      let looped =
        set.contains(state.visited_with_direction, #(
          updated_state.coord,
          updated_state.direction,
        ))
      looped || will_loop(updated_state)
    }
  }
}

fn walk(state: State) -> State {
  let next_coord = next_coord(state)

  let new_state = case dict.get(state.map, next_coord) {
    Ok("#") -> {
      let next_direction = rotate(state.direction)
      State(
        ..state,
        direction: next_direction,
        visited_with_direction: set.insert(state.visited_with_direction, #(
          state.coord,
          next_direction,
        )),
      )
    }

    Ok(_) -> {
      State(
        ..state,
        coord: next_coord,
        visited: set.insert(state.visited, state.coord),
        visited_with_direction: set.insert(state.visited_with_direction, #(
          next_coord,
          state.direction,
        )),
      )
    }

    Error(_) -> State(..state, finished: True)
  }

  new_state
}

fn next_coord(state: State) -> Coord {
  let #(x, y) = state.coord

  case state.direction {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
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
// fn print_map(state: State) {
//   list.range(0, 9)
//   |> list.each(fn(y) {
//     list.range(0, 9)
//     |> list.each(fn(x) {
//       case state.coord == #(x, y) && !state.finished {
//         True ->
//           case state.direction {
//             Up -> io.print("^")
//             Down -> io.print("v")
//             Left -> io.print("<")
//             Right -> io.print(">")
//           }

//         False -> io.print(dict.get(state.map, #(x, y)) |> result.unwrap("?"))
//       }
//     })

//     io.print("\n")
//   })
// }
