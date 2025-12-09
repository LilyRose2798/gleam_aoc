import aoc/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn parse(input: String) -> List(Coord) {
  utils.parsed_lines(input, fn(line) {
    let assert Ok(#(x, y)) = string.split_once(line, ",")
      as "Expected two comma separated fields"
    Coord(x: utils.unsafe_int_parse(x), y: utils.unsafe_int_parse(y))
  })
}

fn area(a: Coord, b: Coord) -> Int {
  { int.absolute_value(a.x - b.x) + 1 } * { int.absolute_value(a.y - b.y) + 1 }
}

pub fn pt_1(tiles: List(Coord)) {
  let assert Ok(max) =
    list.combination_pairs(tiles)
    |> list.map(fn(p) { area(p.0, p.1) })
    |> list.max(int.compare)
    as "Expected non-empty list"
  max
}

fn has_inclusions(tile_pairs: List(#(Coord, Coord)), a: Coord, b: Coord) {
  let #(min_x, max_x) = case a, b {
    a, b if a.x <= b.x -> #(a.x, b.x)
    a, b -> #(b.x, a.x)
  }
  let #(min_y, max_y) = case a, b {
    a, b if a.y <= b.y -> #(a.y, b.y)
    a, b -> #(b.y, a.y)
  }
  list.any(tile_pairs, fn(pos) {
    case pos {
      #(a, b) if a.x == b.x -> {
        let x = a.x
        let #(from_y, to_y) = case a, b {
          a, b if a.y <= b.y -> #(a.y, b.y)
          a, b -> #(b.y, a.y)
        }
        x > min_x && x < max_x && from_y < max_y && to_y > min_y
      }
      #(a, b) -> {
        let y = a.y
        let #(from_x, to_x) = case a, b {
          a, b if a.x <= b.x -> #(a.x, b.x)
          a, b -> #(b.x, a.x)
        }
        y > min_y && y < max_y && from_x < max_x && to_x > min_x
      }
    }
  })
}

pub fn pt_2(tiles: List(Coord)) {
  let assert Ok(last) = list.last(tiles)
  let tile_pairs = list.window_by_2([last, ..tiles])
  let assert Ok(#(_, _, max)) =
    list.combination_pairs(tiles)
    |> list.map(fn(p) { #(p.0, p.1, area(p.0, p.1)) })
    |> list.sort(fn(a, b) {
      case a.2, b.2 {
        a, b if a < b -> order.Gt
        a, b if a > b -> order.Lt
        _, _ -> order.Eq
      }
    })
    |> list.find(fn(p) { !has_inclusions(tile_pairs, p.0, p.1) })
    as "No boxes without inclusions found"
  max
}
