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
  |> list.map(fn(group) {
    // io.println(
    //   "group with " <> { count_corners(group) |> int.to_string } <> " corners",
    // )
    // print_map(map, group)
    // io.println("")

    calculate_fence_cost(group)
  })
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

fn calculate_fence_cost(group: Group) -> Int {
  let area = set.size(group)
  let corners = count_corners(group)
  area * corners
}

fn count_corners(group: Group) {
  group
  |> set.to_list
  |> list.map(fn(coord) {
    [#(1, 1), #(1, -1), #(-1, 1), #(-1, -1)]
    |> list.map(fn(offset) {
      let #(x, y) = coord
      let #(ox, oy) = offset
      let x_neighbor = #(x + ox, y)
      let y_neighbor = #(x, y + oy)
      let diagonal_neighbor = #(x + ox, y + oy)

      let external_corner = case
        !set.contains(group, x_neighbor) && !set.contains(group, y_neighbor)
      {
        True -> 1
        False -> 0
      }

      let internal_corner = case
        set.contains(group, x_neighbor)
        && set.contains(group, y_neighbor)
        && !set.contains(group, diagonal_neighbor)
      {
        True -> 1
        False -> 0
      }

      external_corner + internal_corner
    })
    |> list.reduce(fn(a, b) { a + b })
    |> result.unwrap(0)
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
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
// fn print_map(map: Map, group: Group) {
//   let max_x =
//     dict.keys(map)
//     |> list.map(fn(coord) { coord.0 })
//     |> list.sort(by: int.compare)
//     |> list.last
//     |> result.unwrap(0)
//
//   let max_y =
//     dict.keys(map)
//     |> list.map(fn(coord) { coord.1 })
//     |> list.sort(by: int.compare)
//     |> list.last
//     |> result.unwrap(0)
//
//   list.range(0, max_y)
//   |> list.each(fn(y) {
//     list.range(0, max_x)
//     |> list.each(fn(x) {
//       let assert Ok(char) = dict.get(map, #(x, y))
//
//       case set.contains(group, #(x, y)) {
//         True -> io.print(char)
//         False -> io.print(".")
//       }
//     })
//     io.print("\n")
//   })
// }
