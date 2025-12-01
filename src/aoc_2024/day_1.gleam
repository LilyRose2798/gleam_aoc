import aoc/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/result

pub type Lists {
  Lists(left: List(Int), right: List(Int))
}

pub fn parse(input: String) -> Lists {
  let assert [left, right] =
    utils.parsed_line_fields(input, utils.unsafe_int_parse)
    |> list.transpose
  Lists(left:, right:)
}

pub fn pt_1(lists: Lists) -> Int {
  list.map2(
    list.sort(lists.left, int.compare),
    list.sort(lists.right, int.compare),
    utils.int_distance,
  )
  |> int.sum
}

pub fn pt_2(lists: Lists) -> Int {
  let counts = utils.counts(lists.right)
  list.map(lists.left, fn(x) { x * { dict.get(counts, x) |> result.unwrap(0) } })
  |> int.sum
}
