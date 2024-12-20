import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, String)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day20/input.txt")

  let #(map, start, end) = parse_input(input)

  let steps = build_steps(map, start, end)

  build_shortcuts(map, steps)
  |> list.filter(fn(steps_saved) { steps_saved >= 100 })
  |> list.length
  |> int.to_string
}

fn build_shortcuts(map: Map, steps: Dict(Coord, Int)) {
  map
  |> dict.filter(fn(_, value) { value == "." })
  |> dict.keys
  |> list.flat_map(fn(coord) {
    let #(x, y) = coord

    [#(x - 2, y), #(x + 2, y), #(x, y - 2), #(x, y + 2)]
    |> list.map(fn(another_coord) {
      attempt_shortcut(coord, another_coord, steps)
    })
    |> list.filter(fn(v) { v > 0 })
  })
}

fn attempt_shortcut(
  coord: Coord,
  another_coord: Coord,
  step_dict: Dict(Coord, Int),
) {
  let assert Ok(steps) = dict.get(step_dict, coord)

  case dict.get(step_dict, another_coord) {
    Ok(another_steps) -> {
      case steps > another_steps {
        True -> steps - another_steps - 2
        False -> 0
      }
    }
    _ -> 0
  }
}

fn build_steps(map: Map, start: Coord, end: Coord) -> Dict(Coord, Int) {
  let steps = dict.from_list([#(start, 0)])
  let visited = set.new()
  let next = [start]

  build_steps_loop(map, end, steps, visited, next)
}

fn build_steps_loop(
  map: Map,
  end: Coord,
  steps: Dict(Coord, Int),
  visited: Set(Coord),
  next: List(Coord),
) -> Dict(Coord, Int) {
  let assert [current, ..next] = next

  let assert Ok(current_steps) = dict.get(steps, current)

  let visited = set.insert(visited, current)

  let neighbors = get_unvisited_neighbors(map, visited, current)

  let steps =
    list.fold(neighbors, from: steps, with: fn(steps, neighbor) {
      dict.insert(steps, neighbor, current_steps + 1)
    })

  let next = list.flatten([next, neighbors])

  case next {
    [] -> steps
    _ -> build_steps_loop(map, end, steps, visited, next)
  }
}

fn get_unvisited_neighbors(
  map: Map,
  visited: Set(Coord),
  coord: Coord,
) -> List(Coord) {
  let #(x, y) = coord

  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.filter(fn(neighbor) {
    !set.contains(visited, neighbor)
    && dict.get(map, neighbor) |> result.unwrap("") == "."
  })
}

fn parse_input(input: String) -> #(Dict(Coord, String), Coord, Coord) {
  let map =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.split("")
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten

  let assert Ok(#(start_coord, _)) = list.find(map, fn(item) { item.1 == "S" })
  let assert Ok(#(end_coord, _)) = list.find(map, fn(item) { item.1 == "E" })

  let map =
    map
    |> dict.from_list
    |> dict.insert(start_coord, ".")
    |> dict.insert(end_coord, ".")

  #(map, start_coord, end_coord)
}
