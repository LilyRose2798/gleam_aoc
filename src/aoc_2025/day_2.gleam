import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  string.split(input, ",")
  |> list.map(fn(range) {
    let assert Ok(#(first, last)) = string.split_once(range, "-")
      as { "Invalid id range \"" <> range <> "\"" }
    #(utils.unsafe_int_parse(first), utils.unsafe_int_parse(last))
  })
}

fn repeat_int(base: Int, mul: Int, by amount: Int) -> Int {
  do_repeat_int(base, mul, amount, base)
}

fn do_repeat_int(base: Int, mul: Int, amount: Int, acc) -> Int {
  case amount {
    1 -> acc
    _ -> do_repeat_int(base, mul, amount - 1, mul * acc + base)
  }
}

pub fn solve(ranges: List(#(Int, Int)), pt_1: Bool) -> Int {
  let assert Ok(max_id) =
    list.flat_map(ranges, fn(r) { [r.0, r.1] }) |> list.max(int.compare)
  let max_id_len = int.to_string(max_id) |> string.length
  list.range(1, max_id_len / 2)
  |> list.flat_map(fn(seq_len) {
    let mul = utils.int_power(10, seq_len)
    let range = list.range(mul / 10, mul - 1)
    case pt_1 {
      True -> [2]
      False -> list.range(2, max_id_len / seq_len)
    }
    |> list.flat_map(fn(num_groups) {
      list.map(range, repeat_int(_, mul, num_groups))
    })
  })
  |> list.filter(fn(id) { list.any(ranges, fn(r) { id >= r.0 && id <= r.1 }) })
  |> list.unique
  |> int.sum
}

pub fn pt_1(ranges: List(#(Int, Int))) -> Int {
  solve(ranges, True)
}

pub fn pt_2(ranges: List(#(Int, Int))) -> Int {
  solve(ranges, False)
}
