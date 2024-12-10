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
  case report {
    [a, b, ..rest] -> b > a && is_report_increasing([b, ..rest])
    [] -> True
    [_] -> True
  }
}

fn is_report_decreasing(report: Report) {
  case report {
    [a, b, ..rest] -> b < a && is_report_decreasing([b, ..rest])
    [] -> True
    [_] -> True
  }
}

fn is_report_diffs_acceptable(report: Report) {
  case report {
    [a, b, ..rest] ->
      is_diff_acceptable(a, b) && is_report_diffs_acceptable([b, ..rest])
    [] -> True
    [_] -> True
  }
}

fn is_diff_acceptable(a: Int, b: Int) {
  let diff = int.absolute_value(a - b)
  diff >= 1 && diff <= 3
}
