import aoc/days/day1/part1 as day1_part1
import aoc/days/day1/part2 as day1_part2
import aoc/days/day11/part1 as day11_part1
import aoc/days/day11/part2 as day11_part2
import aoc/days/day12/part1 as day12_part1
import aoc/days/day2/part1 as day2_part1
import aoc/days/day2/part2 as day2_part2
import aoc/days/day3/part1 as day3_part1
import aoc/days/day3/part2 as day3_part2
import aoc/days/day4/part1 as day4_part1
import aoc/days/day4/part2 as day4_part2
import aoc/days/day5/part1 as day5_part1
import aoc/days/day5/part2 as day5_part2
import aoc/days/day6/part1 as day6_part1
import aoc/days/day6/part2 as day6_part2
import aoc/days/day7/part1 as day7_part1
import aoc/days/day7/part2 as day7_part2
import aoc/days/day9/part1 as day9_part1
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
    ["4", "2"] -> day4_part2.solve()

    ["5", "1"] -> day5_part1.solve()
    ["5", "2"] -> day5_part2.solve()

    ["6", "1"] -> day6_part1.solve()
    ["6", "2"] -> day6_part2.solve()

    ["7", "1"] -> day7_part1.solve()
    ["7", "2"] -> day7_part2.solve()

    ["9", "1"] -> day9_part1.solve()

    ["11", "1"] -> day11_part1.solve()
    ["11", "2"] -> day11_part2.solve()

    ["12", "1"] -> day12_part1.solve()

    [_, _] -> "day or part not found"
    _ -> "usage: ./gleam run 1 1"
  }

  io.println(result)
}
