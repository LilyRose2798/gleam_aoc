import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> #(List(fn(List(Int)) -> Int), List(String)) {
  let assert [operations, ..lines] = utils.lines(input) |> list.reverse
  #(
    utils.parsed_fields(operations, fn(op) {
      case op {
        "+" -> int.sum
        "*" -> int.product
        _ -> panic as { "Invalid operation \"" <> op <> "\"" }
      }
    }),
    list.reverse(lines),
  )
}

pub fn pt_1(input: #(List(fn(List(Int)) -> Int), List(String))) -> Int {
  list.map(input.1, utils.parsed_fields(_, utils.unsafe_int_parse))
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
        string.from_utf_codepoints(col) |> utils.unsafe_int_parse,
        ..cur_group
      ])
    }
  })
  |> fn(p) { list.reverse([p.1, ..p.0]) }
  |> list.zip(input.0)
  |> list.map(fn(p) { p.1(p.0) })
  |> int.sum
}
