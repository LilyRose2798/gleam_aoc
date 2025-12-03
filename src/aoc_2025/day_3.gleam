import aoc/utils
import gleam/int
import gleam/list

pub fn parse(input: String) -> List(List(Int)) {
  utils.parsed_line_fields_by(input, "", utils.unsafe_int_parse)
}

fn keep_till_max(xs: List(Int)) -> #(Int, List(Int)) {
  do_keep_till_max(xs, 0, [], [])
}

fn do_keep_till_max(
  xs: List(Int),
  max: Int,
  kept: List(Int),
  seen: List(Int),
) -> #(Int, List(Int)) {
  case xs {
    [] -> #(max, list.reverse(kept))
    [x, ..xs] if x >= max -> do_keep_till_max(xs, x, seen, [x, ..seen])
    [x, ..xs] -> do_keep_till_max(xs, max, kept, [x, ..seen])
  }
}

fn solve(banks: List(List(Int)), needed: Int) -> Int {
  list.map(banks, fn(bank) {
    let #(reserved, available) = list.reverse(bank) |> list.split(needed - 1)
    do_solve(available, list.reverse(reserved), [])
  })
  |> int.sum
}

fn do_solve(available: List(Int), reserved: List(Int), acc: List(Int)) -> Int {
  let #(max, available) = keep_till_max(available)
  let acc = [max, ..acc]
  case reserved {
    [] -> list.fold_right(acc, 0, fn(acc, x) { 10 * acc + x })
    [new, ..reserved] -> do_solve([new, ..available], reserved, acc)
  }
}

pub fn pt_1(banks: List(List(Int))) -> Int {
  solve(banks, 2)
}

pub fn pt_2(banks: List(List(Int))) -> Int {
  solve(banks, 12)
}
