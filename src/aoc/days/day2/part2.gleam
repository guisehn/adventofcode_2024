import gleam/int
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

type Report =
  List(Int)

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day2/input.txt")

  input
  |> parse_input
  |> list.filter(is_report_safe_ignoring_level)
  |> list.length
  |> int.to_string
}

fn parse_input(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let levels = string.split(line, " ")
    list.map(levels, fn(level) { result.unwrap(int.parse(level), 0) })
  })
}

fn is_report_safe_ignoring_level(report: Report) {
  case is_report_safe(report) {
    True -> True
    False ->
      list.range(0, list.length(report) - 1)
      |> list.any(fn(i) {
        let list_without_level = index_filter(report, fn(_, j) { i != j })
        is_report_safe(list_without_level)
      })
  }
}

fn index_filter(list: List(Int), fun: fn(Int, Int) -> Bool) {
  list
  |> list.index_fold([], fn(acc, value, index) {
    case fun(value, index) {
      True -> [value, ..acc]
      False -> acc
    }
  })
  |> list.reverse()
}

fn is_report_safe(report: Report) {
  { is_report_increasing(report) || is_report_decreasing(report) }
  && is_report_diffs_acceptable(report)
}

fn is_report_increasing(report: Report) {
  check(report, fn(a, b) { b > a })
}

fn is_report_decreasing(report: Report) {
  check(report, fn(a, b) { b < a })
}

fn is_report_diffs_acceptable(report: Report) {
  check(report, fn(a, b) {
    let diff = int.absolute_value(a - b)
    diff >= 1 && diff <= 3
  })
}

fn check(report: Report, fun: fn(Int, Int) -> Bool) {
  let #(is_valid, _) =
    report
    |> list.index_map(fn(x, i) { #(i, x) })
    |> list.fold_until(#(True, 0), fn(acc, item) {
      let #(index, value) = item
      let #(_, prev) = acc

      case index == 0 {
        True -> Continue(#(True, value))
        False -> {
          case fun(value, prev) {
            True -> Continue(#(True, value))
            False -> Stop(#(False, value))
          }
        }
      }
    })

  is_valid
}
