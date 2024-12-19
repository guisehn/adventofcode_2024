import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Cache =
  Dict(String, Int)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day19/input.txt")

  let #(patterns, designs) = parse_input(input)

  let patterns =
    list.map(patterns, fn(pattern) { #(pattern, string.length(pattern)) })

  designs
  |> list.map(fn(design) { count_possible_options(design, patterns) })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn count_possible_options(design: String, patterns: List(#(String, Int))) {
  let cache = dict.new()
  let #(is_possible, _cache) =
    count_possible_options_loop(design, patterns, cache)
  is_possible
}

fn count_possible_options_loop(
  design: String,
  patterns: List(#(String, Int)),
  cache: Cache,
) -> #(Int, Cache) {
  case design {
    "" -> #(1, cache)
    _ -> {
      case dict.get(cache, design) {
        Ok(result) -> #(result, cache)
        Error(_) -> {
          let #(result, cache) =
            list.fold(patterns, from: #(0, cache), with: fn(acc, item) {
              let #(count_acc, cache) = acc
              let #(pattern, length) = item
              case string.starts_with(design, pattern) {
                True -> {
                  let #(count_result, cache) =
                    count_possible_options_loop(
                      design |> string.drop_start(length),
                      patterns,
                      cache,
                    )
                  #(count_acc + count_result, cache)
                }
                False -> #(count_acc, cache)
              }
            })

          #(result, dict.insert(cache, design, result))
        }
      }
    }
  }
}

fn parse_input(input: String) {
  let assert [patterns, designs] = input |> string.trim |> string.split("\n\n")
  let patterns = string.split(patterns, ", ")
  let designs = string.split(designs, "\n")
  #(patterns, designs)
}
