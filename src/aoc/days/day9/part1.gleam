import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

type Block {
  FileBlock(id: Int)
  FreeBlock
}

pub fn solve() {
  let assert Ok(input) = simplifile.read("src/aoc/days/day9/input.txt")
  let input = parse_input(input)

  input
  |> build_disk
  |> compact_files
  |> calculate_checksum
  |> int.to_string
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split("")
  |> list.map(to_int)
}

fn build_disk(input: List(Int)) -> List(Block) {
  let #(_, reversed_block_list) =
    input
    |> list.index_fold(from: #(0, []), with: fn(acc, n, index) {
      let #(last_file_id, blocks) = acc

      case index % 2 == 0 {
        True -> #(last_file_id + 1, [
          list.repeat(FileBlock(last_file_id), n),
          ..blocks
        ])
        False -> #(last_file_id, [list.repeat(FreeBlock, n), ..blocks])
      }
    })

  reversed_block_list |> list.flatten |> list.reverse
}

fn compact_files(block_list: List(Block)) {
  let free_block_indexes = get_free_block_indexes(block_list)

  // this could be a .pop() if we had arrays instead of linked lists :/
  let last_file_blocks = get_last_file_blocks(block_list)

  block_list
  |> block_list_to_block_dict
  |> compact_files_loop(last_file_blocks, free_block_indexes)
  |> block_dict_to_block_list
}

fn compact_files_loop(
  block_dict: Dict(Int, Block),
  last_file_blocks: List(#(Block, Int)),
  free_block_indexes: List(Int),
) {
  case free_block_indexes {
    [] -> block_dict
    [free_block_index, ..free_block_indexes] -> {
      let assert [#(moved_block, removed_index), ..last_file_blocks] =
        last_file_blocks

      case removed_index > free_block_index {
        True ->
          block_dict
          |> dict.insert(free_block_index, moved_block)
          |> dict.delete(removed_index)
          |> compact_files_loop(last_file_blocks, free_block_indexes)

        False ->
          block_dict
          |> dict.delete(free_block_index)
          |> compact_files_loop(last_file_blocks, free_block_indexes)
      }
    }
  }
}

fn block_list_to_block_dict(block_list: List(Block)) {
  block_list
  |> list.index_map(fn(block, i) { #(i, block) })
  |> dict.from_list
}

fn block_dict_to_block_list(block_dict: Dict(Int, Block)) {
  block_dict
  |> dict.to_list
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(item) { item.1 })
}

fn get_last_file_blocks(block_list: List(Block)) {
  block_list
  |> list.index_map(fn(block, index) {
    case block {
      FileBlock(_) -> Some(#(block, index))
      _ -> None
    }
  })
  |> list.reverse
  |> list.filter(option.is_some)
  |> list.map(fn(v) {
    let assert Some(x) = v
    x
  })
}

fn get_free_block_indexes(block_list: List(Block)) {
  block_list
  |> list.index_map(fn(block, index) {
    case block {
      FreeBlock -> Some(index)
      _ -> None
    }
  })
  |> list.filter(option.is_some)
  |> list.map(fn(v) { option.unwrap(v, -1) })
}

fn calculate_checksum(block_list: List(Block)) {
  block_list
  |> list.index_map(fn(block, index) {
    let assert FileBlock(id: id) = block
    id * index
  })
  |> list.reduce(fn(a, b) { a + b })
  |> result.unwrap(0)
}

fn to_int(s: String) {
  s |> int.parse |> result.unwrap(0)
}
