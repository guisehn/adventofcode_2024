import aoc/days/day1/part1 as day1_part1
import aoc/days/day1/part2 as day1_part2
import aoc/days/day2/part1 as day2_part1
import aoc/days/day2/part2 as day2_part2
import aoc/days/day3/part1 as day3_part1
import aoc/days/day3/part2 as day3_part2
import aoc/days/day4/part1 as day4_part1
import argv
import gleam/io

pub fn main() {
  let result = case argv.load().arguments {
    ["1", "1"] -> day1_part1.solve()
    ["1", "2"] -> day1_part2.solve()

    ["2", "1"] -> day2_part1.solve()
    ["2", "2"] -> day2_part2.solve()

    ["3", "1"] -> day3_part1.solve()
    ["3", "2"] -> day3_part2.solve()

    ["4", "1"] -> day4_part1.solve()

    [_, _] -> "day or part not found"
    _ -> "usage: ./gleam run 1 1"
  }

  io.println(result)
}
