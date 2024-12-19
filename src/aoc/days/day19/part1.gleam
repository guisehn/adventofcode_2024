import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/string
import simplifile

type Cache =
  Dict(String, Bool)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day19/input.txt")

  let #(patterns, designs) = parse_input(input)

  let patterns =
    list.map(patterns, fn(pattern) { #(pattern, string.length(pattern)) })

  designs
  |> list.filter(fn(design) { is_design_possible(design, patterns) })
  |> list.length
  |> int.to_string
}

fn is_design_possible(design: String, patterns: List(#(String, Int))) {
  let cache = dict.new()
  let #(is_possible, _cache) = is_design_possible_loop(design, patterns, cache)
  is_possible
}

fn is_design_possible_loop(
  design: String,
  patterns: List(#(String, Int)),
  cache: Cache,
) -> #(Bool, Cache) {
  case design {
    "" -> #(True, cache)
    _ -> {
      case dict.get(cache, design) {
        Ok(result) -> #(result, cache)
        Error(_) -> {
          let #(result, cache) =
            list.fold_until(patterns, #(False, cache), fn(acc, item) {
              let #(_, cache) = acc
              let #(pattern, length) = item
              case string.starts_with(design, pattern) {
                True -> {
                  let #(possible, cache) =
                    is_design_possible_loop(
                      design |> string.drop_start(length),
                      patterns,
                      cache,
                    )
                  case possible {
                    True -> Stop(#(True, cache))
                    False -> Continue(#(False, cache))
                  }
                }
                False -> Continue(#(False, cache))
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
