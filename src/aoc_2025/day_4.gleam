import aoc/utils
import gleam/function
import gleam/int
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
  neighbour_offsets
  |> list.map(add_coords(c, _))
  |> list.map(set.contains(s, _))
  |> list.count(function.identity)
}

fn is_accessible(rolls: Set(Coord), c: Coord) -> Bool {
  set.contains(rolls, c) && num_neighbours(rolls, c) < 4
}

pub fn pt_1(grid: Grid) -> Int {
  list.map(list.range(0, grid.height), fn(y) {
    list.count(list.range(0, grid.width), fn(x) {
      is_accessible(grid.rolls, Coord(x:, y:))
    })
  })
  |> int.sum
}

fn remove_accessible(grid: Grid) -> #(Grid, Int) {
  let #(rolls, removed) =
    list.fold(list.range(0, grid.height), #(grid.rolls, 0), fn(acc, y) {
      list.fold(list.range(0, grid.width), #(acc.0, acc.1), fn(acc, x) {
        let c = Coord(x:, y:)
        case is_accessible(acc.0, c) {
          False -> acc
          True -> #(set.delete(acc.0, c), acc.1 + 1)
        }
      })
    })
  #(Grid(..grid, rolls:), removed)
}

fn remove_all_accessible(grid: Grid) -> #(Grid, Int) {
  do_remove_all_accessible(grid, 0)
}

fn do_remove_all_accessible(grid: Grid, removed: Int) -> #(Grid, Int) {
  let #(new_grid, new_removed) = remove_accessible(grid)
  case new_removed {
    0 -> #(grid, removed)
    _ -> do_remove_all_accessible(new_grid, removed + new_removed)
  }
}

pub fn pt_2(grid: Grid) -> Int {
  remove_all_accessible(grid).1
}
