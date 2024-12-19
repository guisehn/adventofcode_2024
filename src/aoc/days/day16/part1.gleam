import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

const infinity = 999_999_999_999_999

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, String)

type Position =
  #(Coord, Direction)

type Direction {
  North
  South
  West
  East
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day16/input.txt")

  let #(map, start, end) = parse_input(input)

  dijkstra(map, start, end) |> string.inspect
}

fn dijkstra(map: Map, start: Coord, end: Coord) {
  let visited = set.new()
  let distances =
    dict.from_list([
      #(#(start, East), 0),
      #(#(start, South), 1000),
      #(#(start, North), 1000),
    ])
  let queue = [#(start, East), #(start, South), #(start, North)]

  dijkstra_loop(map, distances, visited, queue, 0)
  |> dict.to_list
  |> list.filter(fn(item) {
    let #(#(coord, _direction), _distance) = item
    coord == end
  })
  |> list.map(fn(item) {
    let #(#(_coord, _direction), distance) = item
    distance
  })
  |> list.sort(by: int.compare)
  |> list.first
  |> result.unwrap(0)
}

fn dijkstra_loop(
  map: Map,
  distances: Dict(Position, Int),
  visited: Set(Position),
  queue: List(Position),
  i: Int,
) {
  let assert [current_node, ..queue] = queue
  let assert Ok(current_distance) = dict.get(distances, current_node)

  let neighbors = get_unvisited_neighbors(map, visited, current_node)

  let #(_, current_node_direction) = current_node

  let distances =
    neighbors
    |> list.fold(from: distances, with: fn(distances, neighbor) {
      let stored_distance =
        dict.get(distances, neighbor) |> result.unwrap(infinity)
      let #(_, neighbor_direction) = neighbor

      let distance = case current_node_direction == neighbor_direction {
        True -> current_distance + 1
        False -> current_distance + 1000 + 1
      }

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
    _ -> dijkstra_loop(map, distances, visited, queue, i + 1)
  }
}

fn get_unvisited_neighbors(
  map: Map,
  visited: Set(Position),
  current_node: Position,
) {
  let #(coord, direction) = current_node
  let #(x, y) = coord

  let neighbor_coords = case direction {
    North -> [#(x, y - 1), #(x - 1, y), #(x + 1, y)]
    South -> [#(x, y + 1), #(x - 1, y), #(x + 1, y)]
    West -> [#(x, y + 1), #(x, y - 1), #(x - 1, y)]
    East -> [#(x, y + 1), #(x, y - 1), #(x + 1, y)]
  }

  neighbor_coords
  |> list.map(fn(neighbor_coord) {
    #(neighbor_coord, calc_direction(coord, neighbor_coord))
  })
  |> list.filter(fn(neighbor) {
    !set.contains(visited, neighbor)
    && dict.get(map, neighbor.0) |> result.unwrap("") == "."
  })
}

fn calc_direction(coord1: Coord, coord2: Coord) {
  let #(x1, y1) = coord1
  let #(x2, y2) = coord2
  case True {
    _ if x1 == x2 && y2 < y1 -> North
    _ if x1 == x2 && y2 > y1 -> South
    _ if y1 == y2 && x2 > x1 -> East
    _ if y1 == y2 && x2 < x1 -> West
    _ -> panic as { "unknown direction" }
  }
}

fn parse_input(input: String) -> #(Dict(Coord, String), Coord, Coord) {
  let map =
    input
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
