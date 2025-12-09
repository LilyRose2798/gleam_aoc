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

pub fn pt_1(tiles: List(Coord)) -> Int {
  let assert Ok(max) =
    list.combination_pairs(tiles)
    |> list.map(fn(p) { area(p.0, p.1) })
    |> list.max(int.compare)
    as "Expected non-empty list"
  max
}

type Edge {
  Edge(from: Coord, to: Coord)
}

pub fn pt_2(tiles: List(Coord)) -> Int {
  let assert Ok(last) = list.last(tiles)
  let edges =
    list.window_by_2([last, ..tiles])
    |> list.map(fn(p) { Edge(from: p.0, to: p.1) })
  let assert Ok(#(_, _, max_area)) =
    list.combination_pairs(tiles)
    |> list.map(fn(p) { #(p.0, p.1, area(p.0, p.1)) })
    |> list.sort(fn(a, b) {
      case a.2, b.2 {
        a, b if a < b -> order.Gt
        a, b if a > b -> order.Lt
        _, _ -> order.Eq
      }
    })
    |> list.find(fn(p) {
      let #(min_x, max_x) = case p {
        #(a, b, _) if a.x <= b.x -> #(a.x, b.x)
        #(a, b, _) -> #(b.x, a.x)
      }
      let #(min_y, max_y) = case p {
        #(a, b, _) if a.y <= b.y -> #(a.y, b.y)
        #(a, b, _) -> #(b.y, a.y)
      }
      !list.any(edges, fn(edge) {
        case edge {
          Edge(from:, to:) if from.x == to.x -> {
            let x = from.x
            let #(from_y, to_y) = case from, to {
              from, to if from.y <= to.y -> #(from.y, to.y)
              from, to -> #(to.y, from.y)
            }
            x > min_x && x < max_x && to_y > min_y && from_y < max_y
          }
          Edge(from:, to:) -> {
            let y = from.y
            let #(from_x, to_x) = case from, to {
              from, to if from.x <= to.x -> #(from.x, to.x)
              from, to -> #(to.x, from.x)
            }
            y > min_y && y < max_y && to_x > min_x && from_x < max_x
          }
        }
      })
    })
    as "No boxes without inclusions found"
  max_area
}
