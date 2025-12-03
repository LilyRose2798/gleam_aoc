import aoc/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/pair

pub fn parse(input: String) -> List(List(Int)) {
  utils.parsed_line_fields_by(input, "", utils.unsafe_int_parse)
}

fn solve(banks: List(List(Int)), needed: Int) -> Int {
  list.map(banks, fn(bank) {
    do_solve(
      list.index_map(bank, pair.new)
        |> list.sort(fn(a, b) {
          order.break_tie(
            in: int.compare(b.0, a.0),
            with: int.compare(a.1, b.1),
          )
        }),
      needed,
      [],
    )
  })
  |> int.sum
}

fn do_solve(batteries: List(#(Int, Int)), needed: Int, acc: List(Int)) -> Int {
  case needed {
    0 -> list.fold_right(acc, 0, fn(acc, x) { 10 * acc + x })
    _ -> {
      let needed = needed - 1
      let assert Ok(#(x, i)) =
        list.find(batteries, fn(b) {
          list.count(batteries, fn(c) { c.1 > b.1 }) >= needed
        })
      do_solve(list.filter(batteries, fn(b) { b.1 > i }), needed, [x, ..acc])
    }
  }
}

pub fn pt_1(banks: List(List(Int))) -> Int {
  solve(banks, 2)
}

pub fn pt_2(banks: List(List(Int))) -> Int {
  solve(banks, 12)
}
