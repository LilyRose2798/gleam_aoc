import aoc/utils
import gleam/function
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Grid {
  Grid(width: Int, height: Int, rolls: Set(Coord))
}

pub fn parse(input: String) -> Grid {
  let ls = utils.lines(input)
  let height = list.length(ls)
  let assert [first, ..] = ls
  let width = string.length(first)
  let rolls =
    list.index_fold(ls, set.new(), fn(rolls, l, y) {
      list.index_fold(string.split(l, ""), rolls, fn(rolls, c, x) {
        case c {
          "." -> rolls
          "@" -> set.insert(rolls, Coord(x:, y:))
          _ -> panic as { "Invalid input character '" <> c <> "'" }
        }
      })
    })
  Grid(width:, height:, rolls:)
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

fn is_accessible(rolls: Set(Coord), c: Coord) -> Bool {
  list.map(neighbours(c), set.contains(rolls, _))
  |> list.count(function.identity)
  < 4
}

pub fn pt_1(grid: Grid) -> Int {
  set.filter(grid.rolls, is_accessible(grid.rolls, _)) |> set.size
}

fn flood_remove(acc: #(Set(Coord), Int), c: Coord) -> #(Set(Coord), Int) {
  case set.contains(acc.0, c) && is_accessible(acc.0, c) {
    False -> acc
    True ->
      list.fold(neighbours(c), #(set.delete(acc.0, c), acc.1 + 1), flood_remove)
  }
}

pub fn pt_2(grid: Grid) -> Int {
  set.fold(grid.rolls, #(grid.rolls, 0), flood_remove).1
}
