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

const neighbour_offsets = [
  Coord(x: -1, y: -1),
  Coord(x: -1, y: 1),
  Coord(x: 1, y: -1),
  Coord(x: 1, y: 1),
  Coord(x: 0, y: -1),
  Coord(x: 0, y: 1),
  Coord(x: 1, y: 0),
  Coord(x: -1, y: 0),
]

fn add_coords(a: Coord, b: Coord) -> Coord {
  Coord(x: a.x + b.x, y: a.y + b.y)
}

fn num_neighbours(s: Set(Coord), c: Coord) -> Int {
  list.map(neighbour_offsets, add_coords(c, _))
  |> list.map(set.contains(s, _))
  |> list.count(function.identity)
}

fn is_accessible(rolls: Set(Coord), c: Coord) -> Bool {
  set.contains(rolls, c) && num_neighbours(rolls, c) < 4
}

pub fn pt_1(grid: Grid) -> Int {
  set.filter(grid.rolls, is_accessible(grid.rolls, _)) |> set.size
}

fn do_flood_remove(acc: #(Set(Coord), Int), c: Coord) -> #(Set(Coord), Int) {
  case is_accessible(acc.0, c) {
    False -> acc
    True ->
      list.map(neighbour_offsets, add_coords(c, _))
      |> list.fold(#(set.delete(acc.0, c), acc.1 + 1), do_flood_remove)
  }
}

pub fn pt_2(grid: Grid) -> Int {
  set.fold(grid.rolls, #(grid.rolls, 0), do_flood_remove).1
}
