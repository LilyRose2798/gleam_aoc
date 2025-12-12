import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub type Region {
  Region(area: Int, required_shapes: Int)
}

pub fn parse(input: String) -> List(Region) {
  let assert Ok(regions) = string.split(input, "\n\n") |> list.last
  utils.parsed_lines(regions, fn(line) {
    let assert Ok(#(dimensions, required_shapes)) =
      string.split_once(line, ": ")
    let assert Ok(#(width, height)) = string.split_once(dimensions, "x")
    let area = utils.unsafe_int_parse(width) * utils.unsafe_int_parse(height)
    let required_shapes =
      string.split(required_shapes, " ")
      |> list.map(utils.unsafe_int_parse)
      |> int.sum
    Region(area:, required_shapes:)
  })
}

fn solve(regions: List(Region)) -> Int {
  list.count(regions, fn(r) { 9 * r.required_shapes <= r.area })
}

pub fn pt_1(regions: List(Region)) -> Int {
  solve(regions)
}

pub fn pt_2(regions: List(Region)) -> Int {
  solve(regions)
}
