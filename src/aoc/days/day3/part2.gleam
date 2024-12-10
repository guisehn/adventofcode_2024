import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import simplifile

type State {
  State(enabled: Bool, sum: Int)
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day3/input.txt")
  let assert Ok(re) =
    regexp.from_string("(mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\))")

  let result =
    regexp.scan(re, input)
    |> list.fold(
      from: State(enabled: True, sum: 0),
      with: fn(state, instruction) {
        case instruction.submatches {
          [Some("do()")] -> State(enabled: True, sum: state.sum)

          [Some("don't()")] -> State(enabled: False, sum: state.sum)

          [Some("mul(" <> _), Some(a), Some(b)] -> {
            case state {
              State(enabled: True, sum: sum) -> {
                let a = result.unwrap(int.parse(a), 0)
                let b = result.unwrap(int.parse(b), 0)
                State(enabled: True, sum: sum + a * b)
              }
              State(enabled: False, sum: _) -> state
            }
          }

          _ -> state
        }
      },
    )

  int.to_string(result.sum)
}
