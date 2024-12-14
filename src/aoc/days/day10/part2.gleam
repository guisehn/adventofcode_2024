import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, Int)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day10/input.txt")
  let map = parse_input(input)

  map
  |> get_trailheads
  |> list.map(fn(trailhead) { calc_trailhead_rating(map, trailhead) })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn get_trailheads(map: Map) {
  map
  |> dict.to_list
  |> list.filter(fn(item) {
    let #(_, value) = item
    value == 0
  })
  |> list.map(fn(item) {
    let #(coord, _) = item
    coord
  })
}

fn calc_trailhead_rating(map: Map, coord: Coord) {
  let value = get(map, coord)

  case value {
    9 -> 1
    _ -> {
      let #(x, y) = coord

      [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
      |> list.map(fn(neighbor_coord) {
        #(get(map, neighbor_coord), neighbor_coord)
      })
      |> list.filter(fn(neighbor) { neighbor.0 == value + 1 })
      |> list.map(fn(neighbor) { calc_trailhead_rating(map, neighbor.1) })
      |> list.reduce(fn(a, b) { a + b })
      |> result.unwrap(0)
    }
  }
}

fn get(map: Map, coord: Coord) {
  dict.get(map, coord) |> result.unwrap(-1)
}

fn parse_input(input: String) -> Map {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    let cols = string.split(row, "")
    list.index_map(cols, fn(value, x) { #(#(x, y), to_int(value)) })
  })
  |> list.flatten
  |> dict.from_list
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
