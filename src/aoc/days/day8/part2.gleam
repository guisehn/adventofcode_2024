import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day8/input.txt")

  let #(antennas_by_frequency, width, height) = parse_input(input)

  antennas_by_frequency
  |> dict.map_values(fn(_, coords) {
    get_all_antinode_coords(coords, width, height)
  })
  |> dict.to_list
  |> list.flat_map(fn(item) { item.1 })
  |> list.unique
  |> list.length
  |> int.to_string
}

fn get_all_antinode_coords(antenna_coords: List(Coord), width: Int, height: Int) {
  antenna_coords
  |> list.combination_pairs
  |> list.flat_map(fn(pair) {
    get_antinode_coords(pair.0, pair.1, width, height)
  })
  |> list.filter(fn(coord) { is_valid_coord(coord, width, height) })
}

fn get_antinode_coords(
  antenna1: Coord,
  antenna2: Coord,
  width: Int,
  height: Int,
) {
  let #(#(x1, y1), #(x2, y2)) = #(antenna1, antenna2)

  let #(min_x, min_y) = #(int.min(x1, x2), int.min(y1, y2))

  let #(diff_x, diff_y) = #(
    int.absolute_value(x1 - x2),
    int.absolute_value(y1 - y2),
  )

  let #(direction1, direction2) = #(
    get_antinode_direction(antenna1, min_x, min_y, diff_x, diff_y),
    get_antinode_direction(antenna2, min_x, min_y, diff_x, diff_y),
  )

  list.flatten([
    [antenna1, antenna2],
    get_antinode_coords_loop(antenna1, direction1, width, height, []),
    get_antinode_coords_loop(antenna2, direction2, width, height, []),
  ])
}

fn get_antinode_coords_loop(
  coord: Coord,
  direction: Coord,
  width: Int,
  height: Int,
  acc_list: List(Coord),
) {
  let new_coord = #(coord.0 + direction.0, coord.1 + direction.1)
  case is_valid_coord(new_coord, width, height) {
    True ->
      get_antinode_coords_loop(new_coord, direction, width, height, [
        new_coord,
        ..acc_list
      ])
    False -> acc_list
  }
}

fn get_antinode_direction(
  antenna: Coord,
  min_x: Int,
  min_y: Int,
  diff_x: Int,
  diff_y: Int,
) -> Coord {
  let #(x, y) = antenna
  #(
    case x == min_x {
      True -> -diff_x
      False -> diff_x
    },
    case y == min_y {
      True -> -diff_y
      False -> diff_y
    },
  )
}

fn is_valid_coord(coord: Coord, width: Int, height: Int) {
  let #(x, y) = coord
  x >= 0 && x < width && y >= 0 && y < height
}

fn parse_input(input: String) {
  let lines = string.split(input, "\n")
  let height = list.length(lines)

  let map =
    list.index_map(lines, fn(line, y) {
      line
      |> string.split("")
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })

  let width = list.first(map) |> result.unwrap([]) |> list.length

  let groups =
    map
    |> list.flatten
    |> list.group(by: fn(item) { item.1 })
    |> dict.map_values(fn(_, items) { list.map(items, fn(item) { item.0 }) })
    |> dict.delete(".")

  #(groups, width, height)
}
