import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type LockOrKey {
  Lock(heights: List(Int))
  Key(heights: List(Int))
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day25/input.txt")

  let #(keys, locks) = parse_input(input)

  list.flat_map(keys, fn(key) {
    list.filter(locks, fn(lock) { opens_lock(key, lock) })
  })
  |> list.length
  |> int.to_string
}

fn parse_input(input: String) {
  let all =
    input
    |> string.trim
    |> string.split("\n\n")
    |> list.map(fn(item) {
      let lines = string.split(item, "\n")

      let heights =
        lines
        |> list.map(fn(line) { string.split(line, "") })
        |> list.transpose()
        |> list.map(fn(level) {
          list.count(level, fn(char) { char == "#" }) - 1
        })

      let is_lock =
        list.first(lines) |> result.unwrap("") == "#####"
        && list.last(lines) |> result.unwrap("") == "....."

      case is_lock {
        True -> Lock(heights)
        False -> Key(heights)
      }
    })

  let keys =
    list.filter(all, fn(item) {
      case item {
        Key(_) -> True
        _ -> False
      }
    })

  let locks =
    list.filter(all, fn(item) {
      case item {
        Lock(_) -> True
        _ -> False
      }
    })

  #(keys, locks)
}

fn opens_lock(key: LockOrKey, lock: LockOrKey) {
  case key, lock {
    Key(_), Lock(_) ->
      list.zip(key.heights, lock.heights)
      |> list.all(fn(combination) { combination.0 + combination.1 <= 5 })

    _, _ -> panic as "you must provide a key and a lock"
  }
}
