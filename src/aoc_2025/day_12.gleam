import aoc/utils
import gleam/int
import gleam/list
import gleam/string

fn solve(input: String) -> Int {
  let assert Ok(regions) = string.split(input, "\n\n") |> list.last
  utils.lines(regions)
  |> list.count(fn(line) {
    let assert Ok(#(dimensions, required_shapes)) =
      string.split_once(line, ": ")
    string.split(required_shapes, " ")
    |> list.map(utils.unsafe_int_parse)
    |> int.sum
    |> int.multiply(9)
    <= string.split(dimensions, "x")
    |> list.map(utils.unsafe_int_parse)
    |> int.product
  })
}

pub fn pt_1(input: String) -> Int {
  solve(input)
}

pub fn pt_2(input: String) -> Int {
  solve(input)
}
