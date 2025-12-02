import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(Int) {
  string.split(input, ",")
  |> list.map(fn(range) {
    let assert Ok(#(first, last)) = string.split_once(range, "-")
      as { "Invalid id range \"" <> range <> "\"" }
    #(utils.unsafe_int_parse(first), utils.unsafe_int_parse(last))
  })
  |> list.flat_map(fn(r) { list.range(r.0, r.1) })
}

pub fn pt_1(ids: List(Int)) -> Int {
  list.filter(ids, fn(id) {
    let s = int.to_string(id)
    let l = string.length(s)
    int.is_even(l) && string.drop_end(s, l / 2) == string.drop_start(s, l / 2)
  })
  |> int.sum
}

pub fn pt_2(ids: List(Int)) -> Int {
  list.filter(ids, fn(id) {
    let s = int.to_string(id)
    let l = string.length(s)
    let cs = string.to_utf_codepoints(s)
    l > 1
    && list.any(list.range(1, l / 2), fn(x) {
      l % x == 0
      && list.sized_chunk(cs, x)
      |> list.unique
      |> list.length
      == 1
    })
  })
  |> int.sum
}
