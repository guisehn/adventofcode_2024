import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

type File {
  File(id: Int, size: Int)
}

type Gap {
  Gap(space_left: Int, files: List(File))
}

type DiskItem {
  FileItem(File)
  GapItem(Gap)
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day9/input.txt")
  let input = parse_input(input)

  input
  |> build_disk
  |> fill_gaps
  |> calculate_checksum
  |> int.to_string
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split("")
  |> list.map(to_int)
}

fn build_disk(input: List(Int)) -> List(DiskItem) {
  let #(_, reversed_item_list) =
    input
    |> list.index_fold(from: #(0, []), with: fn(acc, n, index) {
      let #(last_file_id, disk) = acc

      case index % 2 == 0 {
        True -> #(last_file_id + 1, [
          FileItem(File(id: last_file_id, size: n)),
          ..disk
        ])
        False -> #(last_file_id, [
          GapItem(Gap(space_left: n, files: [])),
          ..disk
        ])
      }
    })

  list.reverse(reversed_item_list)
}

fn fill_gaps(disk: List(DiskItem)) {
  let files_to_move = get_reversed_files(disk)
  let gaps = get_gaps(disk)

  disk
  |> disk_list_to_dict
  |> fill_gaps_loop(files_to_move, gaps)
  |> disk_dict_to_list
}

fn fill_gaps_loop(
  disk_dict: Dict(Int, DiskItem),
  files_to_move: List(#(File, Int)),
  gaps: List(#(Gap, Int)),
) {
  case files_to_move {
    [] -> disk_dict

    [#(file, file_index), ..files_to_move] -> {
      let gap_found =
        list.find(gaps, fn(item) {
          let #(Gap(space_left: gap_space_left, ..), gap_index) = item
          gap_index < file_index && gap_space_left >= file.size
        })

      case gap_found {
        Ok(#(gap, gap_index)) -> {
          let updated_gap =
            Gap(
              files: [file, ..gap.files],
              space_left: gap.space_left - file.size,
            )

          let new_gap = Gap(space_left: file.size, files: [])

          disk_dict
          |> dict.insert(gap_index, GapItem(updated_gap))
          |> dict.insert(file_index, GapItem(new_gap))
          |> fill_gaps_loop(
            files_to_move,
            update_gap_list(gaps, #(updated_gap, gap_index), #(
              new_gap,
              file_index,
            )),
          )
        }

        Error(_) -> {
          fill_gaps_loop(disk_dict, files_to_move, gaps)
        }
      }
    }
  }
}

fn update_gap_list(
  gaps: List(#(Gap, Int)),
  updated: #(Gap, Int),
  new: #(Gap, Int),
) {
  let #(updated_gap, updated_index) = updated

  let gaps = case updated_gap.space_left {
    0 ->
      list.filter(gaps, fn(gap_and_index) { gap_and_index.1 != updated_index })
    _ ->
      list.map(gaps, fn(gap_and_index) {
        let #(_, index) = gap_and_index
        case updated_index == index {
          True -> #(updated_gap, index)
          False -> gap_and_index
        }
      })
  }

  [new, ..gaps]
  |> list.sort(by: fn(a, b) { int.compare(a.1, b.1) })
}

fn get_gaps(disk: List(DiskItem)) {
  disk
  |> list.index_map(fn(item, index) {
    case item {
      GapItem(gap) -> Some(#(gap, index))
      _ -> None
    }
  })
  |> remove_nones
}

fn get_reversed_files(disk: List(DiskItem)) {
  disk
  |> list.index_map(fn(file, index) {
    case file {
      FileItem(file) -> Some(#(file, index))
      _ -> None
    }
  })
  |> list.reverse
  |> remove_nones
}

fn remove_nones(list: List(Option(l))) {
  list
  |> list.filter(option.is_some)
  |> list.map(fn(option) {
    let assert Some(val) = option
    val
  })
}

fn calculate_checksum(disk: List(DiskItem)) {
  disk
  |> list.flat_map(fn(item) {
    case item {
      FileItem(File(id: id, size: size)) -> list.repeat(id, size)
      GapItem(gap) -> {
        list.flatten([
          gap.files
            |> list.reverse()
            |> list.flat_map(fn(file) { list.repeat(file.id, file.size) }),
          list.repeat(0, gap.space_left),
        ])
      }
    }
  })
  |> list.index_map(fn(id, index) { id * index })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
}

fn disk_list_to_dict(disk: List(DiskItem)) {
  disk
  |> list.index_map(fn(block, i) { #(i, block) })
  |> dict.from_list
}

fn disk_dict_to_list(disk_dict: Dict(Int, DiskItem)) {
  disk_dict
  |> dict.to_list
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(item) { item.1 })
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
