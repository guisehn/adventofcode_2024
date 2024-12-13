import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, String)

type Group =
  Set(Coord)

type GroupList {
  GroupList(groups: List(Group), exclude: Set(Coord))
}

type GroupResult {
  GroupResult(group: Option(Group), visited: Set(Coord))
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day12/input.txt")
  let map = parse_input(input)

  map
  |> build_groups
  |> list.map(calculate_fence_cost)
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn build_groups(map: Map) -> List(Set(Coord)) {
  let result =
    map
    |> dict.fold(
      from: GroupList(groups: [], exclude: set.new()),
      with: fn(acc, coord, plant) {
        case build_group(map, plant, coord, acc.exclude) {
          GroupResult(group: None, ..) -> acc
          GroupResult(group: Some(group), ..) ->
            GroupList(
              groups: [group, ..acc.groups],
              exclude: set.union(acc.exclude, group),
            )
        }
      },
    )

  result.groups
}

fn build_group(
  map: Map,
  plant: String,
  coord: Coord,
  visited: Set(Coord),
) -> GroupResult {
  let plant_found = dict.get(map, coord) |> result.unwrap("")

  case plant_found == plant && !set.contains(visited, coord) {
    True -> {
      let #(x, y) = coord
      let visited = set.insert(visited, coord)

      let GroupResult(group: top_group, visited: visited) =
        build_group(map, plant, #(x, y - 1), visited)
      let GroupResult(group: bottom_group, visited: visited) =
        build_group(map, plant, #(x, y + 1), visited)
      let GroupResult(group: left_group, visited: visited) =
        build_group(map, plant, #(x - 1, y), visited)
      let GroupResult(group: right_group, visited: visited) =
        build_group(map, plant, #(x + 1, y), visited)

      GroupResult(
        group: Some(
          set.from_list([coord])
          |> merge(top_group)
          |> merge(bottom_group)
          |> merge(left_group)
          |> merge(right_group),
        ),
        visited: visited,
      )
    }

    False -> GroupResult(group: None, visited: visited)
  }
}

fn merge(group1: Set(Coord), group2: Option(Set(Coord))) -> Set(Coord) {
  case group2 {
    None -> group1
    Some(group2) -> set.union(group1, group2)
  }
}

fn calculate_fence_cost(group: Set(Coord)) -> Int {
  let area = set.size(group)

  let perimeter =
    group
    |> set.to_list
    |> list.map(fn(coord) {
      let #(x, y) = coord

      let neighbors =
        [#(x, y - 1), #(x, y + 1), #(x - 1, y), #(x + 1, y)]
        |> list.filter(fn(coord) { set.contains(group, coord) })
        |> list.length()

      4 - neighbors
    })
    |> list.reduce(fn(a, b) { a + b })
    |> result.unwrap(0)

  area * perimeter
}

fn parse_input(input: String) -> Map {
  let coord_list =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(row, y) {
      let cols = string.split(row, "")
      list.index_map(cols, fn(value, x) { #(#(x, y), value) })
    })
    |> list.flatten()

  dict.from_list(coord_list)
}
