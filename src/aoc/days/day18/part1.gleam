import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, String)

const width = 71

const height = 71

const max_byte = 1024

const infinity = 999_999_999_999_999

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day18/input.txt")

  let map = parse_input(input) |> build_map
  let start = #(0, 0)
  let end = #(width - 1, height - 1)

  print_map(map, set.new())

  dijkstra(map, start, end) |> int.to_string
}

fn dijkstra(map: Map, start: Coord, end: Coord) {
  let distances = dict.new() |> dict.insert(start, 0)
  let visited = set.new()
  let queue = [start]

  dijkstra_loop(map, distances, visited, queue)
  |> dict.get(end)
  |> result.unwrap(infinity)
}

fn dijkstra_loop(
  map: Map,
  distances: Dict(Coord, Int),
  visited: Set(Coord),
  queue: List(Coord),
) {
  let assert [current_node, ..queue] = queue
  let assert Ok(current_distance) = dict.get(distances, current_node)

  let neighbors = get_unvisited_neighbors(map, visited, current_node)

  let distances =
    neighbors
    |> list.fold(from: distances, with: fn(distances, neighbor) {
      let stored_distance =
        dict.get(distances, neighbor) |> result.unwrap(infinity)

      let distance = current_distance + 1

      case distance < stored_distance {
        True -> dict.insert(distances, neighbor, distance)
        False -> distances
      }
    })

  let visited = set.insert(visited, current_node)

  let queue =
    list.flatten([queue, neighbors])
    |> list.unique
    |> list.sort(by: fn(a, b) {
      let assert Ok(dist_a) = dict.get(distances, a)
      let assert Ok(dist_b) = dict.get(distances, b)
      int.compare(dist_a, dist_b)
    })

  case queue {
    [] -> distances
    _ -> dijkstra_loop(map, distances, visited, queue)
  }
}

fn get_unvisited_neighbors(map: Map, visited: Set(Coord), current_node: Coord) {
  let #(x, y) = current_node

  [#(x, y - 1), #(x, y + 1), #(x - 1, y), #(x + 1, y)]
  |> list.filter(fn(neighbor) {
    !set.contains(visited, neighbor)
    && dict.get(map, neighbor) |> result.unwrap("") == "."
  })
}

fn parse_input(input: String) -> Set(Coord) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(row) {
    let assert [x, y] = string.split(row, ",")
    #(to_int(x), to_int(y))
  })
  |> list.take(max_byte)
  |> set.from_list
}

fn build_map(walls: Set(Coord)) -> Map {
  list.range(0, height - 1)
  |> list.flat_map(fn(y) {
    list.range(0, width - 1)
    |> list.map(fn(x) {
      case set.contains(walls, #(x, y)) {
        True -> #(#(x, y), "#")
        False -> #(#(x, y), ".")
      }
    })
  })
  |> dict.from_list
}

fn print_map(map: Map, visited: Set(Coord)) {
  list.range(0, height - 1)
  |> list.each(fn(y) {
    list.range(0, width - 1)
    |> list.each(fn(x) {
      case set.contains(visited, #(x, y)) {
        True -> io.print("x")
        False -> dict.get(map, #(x, y)) |> result.unwrap("") |> io.print
      }
    })
    io.print("\n")
  })
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
