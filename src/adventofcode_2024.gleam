import aoc/days/day1/part1 as day1_part1
import aoc/days/day1/part2 as day1_part2
import aoc/days/day10/part1 as day10_part1
import aoc/days/day10/part2 as day10_part2
import aoc/days/day11/part1 as day11_part1
import aoc/days/day11/part2 as day11_part2
import aoc/days/day12/part1 as day12_part1
import aoc/days/day13/part1 as day13_part1
import aoc/days/day13/part2 as day13_part2
import aoc/days/day14/part1 as day14_part1
import aoc/days/day14/part2 as day14_part2
import aoc/days/day15/part1 as day15_part1
import aoc/days/day15/part2 as day15_part2
import aoc/days/day16/part1 as day16_part1
import aoc/days/day17/part1 as day17_part1
import aoc/days/day18/part1 as day18_part1
import aoc/days/day18/part2 as day18_part2
import aoc/days/day19/part1 as day19_part1
import aoc/days/day19/part2 as day19_part2
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
import aoc/days/day8/part1 as day8_part1
import aoc/days/day8/part2 as day8_part2
import aoc/days/day9/part1 as day9_part1
import aoc/days/day9/part2 as day9_part2
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

    ["8", "1"] -> day8_part1.solve()
    ["8", "2"] -> day8_part2.solve()

    ["9", "1"] -> day9_part1.solve()
    ["9", "2"] -> day9_part2.solve()

    ["10", "1"] -> day10_part1.solve()
    ["10", "2"] -> day10_part2.solve()

    ["11", "1"] -> day11_part1.solve()
    ["11", "2"] -> day11_part2.solve()

    ["12", "1"] -> day12_part1.solve()

    ["13", "1"] -> day13_part1.solve()
    ["13", "2"] -> day13_part2.solve()

    ["14", "1"] -> day14_part1.solve()
    ["14", "2"] -> day14_part2.solve()

    ["15", "1"] -> day15_part1.solve()
    ["15", "2"] -> day15_part2.solve()

    ["16", "1"] -> day16_part1.solve()

    ["17", "1"] -> day17_part1.solve()

    ["18", "1"] -> day18_part1.solve()
    ["18", "2"] -> day18_part2.solve()

    ["19", "1"] -> day19_part1.solve()
    ["19", "2"] -> day19_part2.solve()

    [_, _] -> "day or part not found"
    _ -> "usage: ./gleam run 1 1"
  }

  io.println(result)
}
