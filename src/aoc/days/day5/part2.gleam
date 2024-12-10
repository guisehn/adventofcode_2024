import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/yielder
import simplifile

type RuleList =
  Dict(Int, List(Int))

type Input {
  Input(rules: RuleList, updates: List(List(Int)))
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day5/input.txt")
  let input = parse_input(input)

  input.updates
  |> list.filter(fn(update) { !is_valid_update(update, input.rules) })
  |> list.map(fn(update) { fix_update(update, input.rules) })
  |> list.map(get_middle_page_number)
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
  |> int.to_string
}

fn parse_input(input: String) -> Input {
  let assert [rules, updates] = input |> string.trim |> string.split("\n\n")
  Input(rules: parse_rules(rules), updates: parse_updates(updates))
}

fn parse_rules(lines: String) -> RuleList {
  lines
  |> string.split("\n")
  |> list.fold(from: dict.new(), with: fn(rules, rule) {
    let assert [before, after] = string.split(rule, "|")
    let before = to_int(before)
    let after = to_int(after)

    dict.upsert(rules, before, fn(existing_rule) {
      case existing_rule {
        None -> [after]
        Some(existing) -> [after, ..existing]
      }
    })
  })
}

fn parse_updates(lines: String) -> List(List(Int)) {
  lines
  |> string.split("\n")
  |> list.map(fn(line) { line |> string.split(",") |> list.map(to_int) })
}

fn is_valid_update(update: List(Int), rules: RuleList) {
  case update {
    [a, b, ..rest] -> {
      let rule = dict.get(rules, b)
      case rule {
        Ok(rule) ->
          !list.contains(rule, a) && is_valid_update([b, ..rest], rules)
        Error(_) -> is_valid_update([b, ..rest], rules)
      }
    }

    [_] -> True
    [] -> True
  }
}

fn fix_update(update: List(Int), rules: RuleList) {
  case do_fix_update(update, [], rules) {
    // we may need more than one pass to fix it
    result if result != update -> fix_update(result, rules)
    result -> result
  }
}

fn do_fix_update(update: List(Int), fixed_update: List(Int), rules: RuleList) {
  case update {
    [a, b, ..rest] -> {
      let rule = dict.get(rules, b)
      case rule {
        Ok(rule) -> {
          case list.contains(rule, a) {
            True -> do_fix_update([a, ..rest], [b, ..fixed_update], rules)
            False -> do_fix_update([b, ..rest], [a, ..fixed_update], rules)
          }
        }
        Error(_) -> do_fix_update([b, ..rest], [a, ..fixed_update], rules)
      }
    }
    [x] -> [x, ..fixed_update] |> list.reverse()
    [] -> panic as "list cannot be empty"
  }
}

fn get_middle_page_number(update: List(Int)) {
  update
  |> yielder.from_list
  |> yielder.at(list.length(update) / 2)
  |> result.unwrap(0)
}

fn to_int(str: String) {
  result.unwrap(int.parse(str), 0)
}
