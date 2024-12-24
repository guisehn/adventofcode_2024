import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day23/input.txt")
  let input = parse_input(input)

  let links_dict =
    input
    |> list.fold(from: dict.new(), with: fn(links_dict, link) {
      let #(a, b) = link

      links_dict
      |> dict.upsert(a, fn(l) { option.unwrap(l, set.new()) |> set.insert(b) })
      |> dict.upsert(b, fn(l) { option.unwrap(l, set.new()) |> set.insert(a) })
    })

  links_dict
  |> dict.keys
  |> list.filter(fn(pc) { string.starts_with(pc, "t") })
  |> list.flat_map(fn(pc) {
    dict.get(links_dict, pc)
    |> result.unwrap(set.new())
    |> set.to_list
    |> list.combination_pairs
    |> list.filter(fn(pair) {
      let #(a, b) = pair
      let assert Ok(a_links) = dict.get(links_dict, a)
      set.contains(a_links, b)
    })
    |> list.map(fn(pair) {
      let #(a, b) = pair
      [a, b, pc] |> list.sort(by: string.compare)
    })
  })
  |> list.unique
  |> list.length
  |> int.to_string
}

fn parse_input(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [a, b] = string.split(line, "-")
    #(a, b)
  })
}
