import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> #(List(String), List(fn(List(Int)) -> Int)) {
  let assert [operations, ..lines] = utils.lines(input) |> list.reverse
  #(
    list.reverse(lines),
    utils.parsed_fields(operations, fn(op) {
      case op {
        "+" -> int.sum
        "*" -> int.product
        _ -> panic as { "Invalid operation \"" <> op <> "\"" }
      }
    }),
  )
}

fn solve(nums: List(List(Int)), ops: List(fn(List(Int)) -> Int)) -> Int {
  list.zip(nums, ops)
  |> list.map(fn(p) { p.1(p.0) })
  |> int.sum
}

pub fn pt_1(input: #(List(String), List(fn(List(Int)) -> Int))) -> Int {
  let #(lines, ops) = input
  list.map(lines, utils.parsed_fields(_, utils.unsafe_int_parse))
  |> list.transpose
  |> solve(ops)
}

fn do_group_columns(
  chars: List(List(UtfCodepoint)),
  groups: List(List(Int)),
  cur_group: List(Int),
) -> List(List(Int)) {
  case chars {
    [] -> list.reverse([cur_group, ..groups])
    [[], ..chars] -> do_group_columns(chars, [cur_group, ..groups], [])
    [cs, ..chars] ->
      do_group_columns(chars, groups, [
        string.from_utf_codepoints(cs) |> utils.unsafe_int_parse,
        ..cur_group
      ])
  }
}

pub fn pt_2(input: #(List(String), List(fn(List(Int)) -> Int))) -> Int {
  let #(lines, ops) = input
  let assert Ok(space) = string.utf_codepoint(32)
  list.map(lines, string.to_utf_codepoints)
  |> list.transpose
  |> list.map(list.filter(_, fn(c) { c != space }))
  |> do_group_columns([], [])
  |> solve(ops)
}
