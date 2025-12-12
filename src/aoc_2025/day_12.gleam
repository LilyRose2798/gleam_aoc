import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Region {
  Region(width: Int, height: Int, required_shapes: Dict(Int, Int))
}

pub type PresentData {
  PresentData(shapes: Dict(Int, Set(Coord)), regions: List(Region))
}

pub fn parse(input: String) -> PresentData {
  let assert Ok(hash) = string.utf_codepoint(35)
  let assert [regions, ..shapes] = string.split(input, "\n\n") |> list.reverse
  let shapes =
    list.reverse(shapes)
    |> list.map(fn(shape) {
      let assert [index, ..shape] = utils.lines(shape)
      let index = string.drop_end(index, 1) |> utils.unsafe_int_parse
      let shape =
        list.index_fold(shape, set.new(), fn(acc, line, y) {
          string.to_utf_codepoints(line)
          |> list.index_fold(acc, fn(acc, c, x) {
            case c == hash {
              True -> set.insert(acc, Coord(x:, y:))
              False -> acc
            }
          })
        })
      #(index, shape)
    })
    |> dict.from_list
  let regions =
    utils.parsed_lines(regions, fn(line) {
      let assert Ok(#(dimensions, required_shapes)) =
        string.split_once(line, ": ")
      let assert Ok(#(width, height)) = string.split_once(dimensions, "x")
      let width = utils.unsafe_int_parse(width)
      let height = utils.unsafe_int_parse(height)
      let required_shapes =
        string.split(required_shapes, " ")
        |> list.index_map(fn(x, i) { #(i, utils.unsafe_int_parse(x)) })
        |> dict.from_list
      Region(width:, height:, required_shapes:)
    })
  PresentData(shapes:, regions:)
}

fn solve(present_data: PresentData) -> Int {
  list.count(present_data.regions, fn(region) {
    let Region(width:, height:, required_shapes:) = region
    9 * { dict.values(required_shapes) |> int.sum } <= width * height
  })
}

pub fn pt_1(present_data: PresentData) -> Int {
  solve(present_data)
}

pub fn pt_2(present_data: PresentData) -> Int {
  solve(present_data)
}
