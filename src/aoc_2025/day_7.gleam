import aoc/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> #(Set(Int), List(Set(Int))) {
  let assert Ok(dot) = string.utf_codepoint(46)
  let assert [beam_positions, ..splitter_positions] =
    utils.lines(input)
    |> list.sized_chunk(2)
    |> list.map(fn(lines) {
      let assert [first, _] = lines
      string.to_utf_codepoints(first)
      |> list.index_fold([], fn(acc, c, i) {
        case c == dot {
          True -> acc
          False -> [i, ..acc]
        }
      })
      |> set.from_list
    })
  #(beam_positions, splitter_positions)
}

pub fn pt_1(positions: #(Set(Int), List(Set(Int)))) {
  let #(beam_positions, splitter_positions) = positions
  list.fold(
    splitter_positions,
    #(beam_positions, 0),
    fn(acc, splitter_positions) {
      let #(beam_positions, num_collisions) = acc
      let collisions = set.intersection(beam_positions, splitter_positions)
      #(
        beam_positions
          |> set.difference(splitter_positions)
          |> set.union(set.map(collisions, int.add(_, 1)))
          |> set.union(set.map(collisions, int.subtract(_, 1))),
        num_collisions + set.size(collisions),
      )
    },
  ).1
}

pub fn pt_2(positions: #(Set(Int), List(Set(Int)))) {
  let #(beam_positions, splitter_positions) = positions
  let beam_positions =
    set.to_list(beam_positions) |> list.map(pair.new(_, 1)) |> dict.from_list
  list.fold(
    splitter_positions,
    beam_positions,
    fn(beam_positions, splitter_positions) {
      let #(collisions, non_collisions) =
        list.partition(dict.to_list(beam_positions), fn(p) {
          set.contains(splitter_positions, p.0)
        })
      let left =
        list.map(collisions, pair.map_first(_, int.subtract(_, 1)))
        |> dict.from_list
      let right =
        list.map(collisions, pair.map_first(_, int.add(_, 1))) |> dict.from_list
      dict.from_list(non_collisions)
      |> dict.combine(left, int.add)
      |> dict.combine(right, int.add)
    },
  )
  |> dict.values
  |> int.sum
}
