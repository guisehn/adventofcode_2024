import aoc/days/day1/part1 as day1_part1
import aoc/days/day1/part2 as day1_part2
import argv
import gleam/io

pub fn main() {
  let result = case argv.load().arguments {
    ["1", "1"] -> day1_part1.solve()
    ["1", "2"] -> day1_part2.solve()
    [_, _] -> "day or part not found"
    _ -> "usage: ./gleam run 1 1"
  }

  io.println(result)
}
