import aoc/utils
import gleam/dict.{type Dict}
import gleam/list
import gleam/set
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn parse(input: String) -> Dict(Coord, Int) {
  let l =
    list.index_fold(utils.lines(input), [], fn(rolls, l, y) {
      list.index_fold(string.split(l, ""), rolls, fn(rolls, c, x) {
        case c {
          "." -> rolls
          "@" -> [Coord(x:, y:), ..rolls]
          _ -> panic as { "Invalid input character '" <> c <> "'" }
        }
      })
    })
  let s = set.from_list(l)
  list.map(l, fn(c) { #(c, list.count(neighbours(c), set.contains(s, _))) })
  |> dict.from_list
}

fn neighbours(c: Coord) -> List(Coord) {
  let Coord(x:, y:) = c
  [
    Coord(x: x - 1, y: y - 1),
    Coord(x: x - 1, y: y + 1),
    Coord(x: x + 1, y: y - 1),
    Coord(x: x + 1, y: y + 1),
    Coord(x:, y: y - 1),
    Coord(x:, y: y + 1),
    Coord(x: x + 1, y:),
    Coord(x: x - 1, y:),
  ]
}

pub fn pt_1(rolls: Dict(Coord, Int)) -> Int {
  dict.filter(rolls, fn(_, n) { n < 4 }) |> dict.size
}

fn flood_remove(
  acc: #(Dict(Coord, Int), Int),
  c: Coord,
) -> #(Dict(Coord, Int), Int) {
  let #(d, n, cs) =
    list.fold(neighbours(c), #(acc.0, acc.1, []), fn(acc, c) {
      case dict.get(acc.0, c) {
        Ok(n) if n <= 4 -> #(dict.delete(acc.0, c), acc.1 + 1, [c, ..acc.2])
        Ok(n) -> #(dict.insert(acc.0, c, n - 1), acc.1, acc.2)
        Error(Nil) -> acc
      }
    })
  list.fold(cs, #(d, n), flood_remove)
}

pub fn pt_2(rolls: Dict(Coord, Int)) -> Int {
  let dd = dict.filter(rolls, fn(_, n) { n < 4 })
  let cs = dict.keys(dd)
  list.fold(cs, #(dict.drop(rolls, cs), dict.size(dd)), flood_remove).1
}
