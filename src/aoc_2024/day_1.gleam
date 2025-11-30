import aoc/utils
import gleam/int
import gleam/list

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  utils.parsed_line_fields(input, utils.unsafe_int_parse)
  |> list.transpose
  |> utils.unsafe_list_to_pair
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  list.map2(
    list.sort(input.0, int.compare),
    list.sort(input.1, int.compare),
    utils.int_distance,
  )
  |> int.sum
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let counts = utils.counts(input.1)
  list.map(input.0, fn(x) { x * utils.dict_get_or_default(counts, x, 0) })
  |> int.sum
}
