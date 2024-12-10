import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Board =
  Dict(Coord, String)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day4/input.txt")

  let coord_list = parse_input(input)
  let board = dict.from_list(coord_list)

  coord_list
  |> list.map(fn(item) {
    let #(coord, _) = item
    count_xmas(board, coord)
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn count_xmas(board: Board, coord: Coord) {
  let #(x, y) = coord

  // M S
  //  A
  // M S
  mmass(board, [
    #(x, y),
    #(x, y + 2),
    #(x + 1, y + 1),
    #(x + 2, y),
    #(x + 2, y + 2),
  ])
  // M M
  //  A
  // S S
  + mmass(board, [
    #(x, y),
    #(x + 2, y),
    #(x + 1, y + 1),
    #(x, y + 2),
    #(x + 2, y + 2),
  ])
  // S M
  //  A
  // S M
  + mmass(board, [
    #(x + 2, y),
    #(x + 2, y + 2),
    #(x + 1, y + 1),
    #(x, y),
    #(x, y + 2),
  ])
  // S S
  //  A
  // M M
  + mmass(board, [
    #(x, y + 2),
    #(x + 2, y + 2),
    #(x + 1, y + 1),
    #(x, y),
    #(x + 2, y),
  ])
}

fn mmass(board: Board, coords: List(Coord)) {
  case list.map(coords, fn(coord) { dict.get(board, coord) }) {
    [Ok("M"), Ok("M"), Ok("A"), Ok("S"), Ok("S")] -> 1
    _ -> 0
  }
}

fn parse_input(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    let cols = string.split(row, "")
    list.index_map(cols, fn(value, x) { #(#(x, y), value) })
  })
  |> list.flatten()
}
