import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> #(List(fn(List(Int)) -> Int), List(String)) {
  let assert [operations, ..lines] = utils.lines(input) |> list.reverse
  let operations =
    utils.fields(operations)
    |> list.map(fn(op) {
      case op {
        "+" -> int.sum
        "*" -> int.product
        _ -> panic as { "Invalid operation \"" <> op <> "\"" }
      }
    })
  #(operations, list.reverse(lines))
}

pub fn pt_1(input: #(List(fn(List(Int)) -> Int), List(String))) -> Int {
  list.map(input.1, utils.fields)
  |> list.map(list.map(_, utils.unsafe_int_parse))
  |> list.transpose
  |> list.zip(input.0)
  |> list.map(fn(p) { p.1(p.0) })
  |> int.sum
}

pub fn pt_2(input: #(List(fn(List(Int)) -> Int), List(String))) -> Int {
  let assert Ok(space) = string.utf_codepoint(32)
  list.map(input.1, string.to_utf_codepoints)
  |> list.transpose
  |> list.fold(#([], []), fn(acc, col) {
    let #(groups, cur_group) = acc
    case list.filter(col, fn(x) { x != space }) {
      [] -> #([cur_group, ..groups], [])
      col -> #(groups, [
        list.fold(col, 0, fn(acc, x) {
          10 * acc + string.utf_codepoint_to_int(x) - 48
        }),
        ..cur_group
      ])
    }
  })
  |> fn(p) { list.reverse([p.1, ..p.0]) }
  |> list.zip(input.0)
  |> list.map(fn(p) { p.1(p.0) })
  |> int.sum
}
