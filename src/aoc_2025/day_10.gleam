import aoc/utils
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub type Machine {
  Machine(
    light_diagram: List(Int),
    buttons: List(List(Int)),
    joltages: List(Int),
  )
}

pub fn parse(input: String) -> List(Machine) {
  let assert Ok(hash) = string.utf_codepoint(35)
  utils.parsed_lines(input, fn(line) {
    let assert [light_diagram, ..rest] = string.split(line, " ")
      as "Expected at least two fields"
    let light_diagram =
      string.drop_start(light_diagram, 1)
      |> string.drop_end(1)
      |> string.to_utf_codepoints
      |> list.index_fold([], fn(acc, c, i) {
        case c == hash {
          True -> [i, ..acc]
          False -> acc
        }
      })
      |> list.reverse
    let assert [joltages, ..buttons] =
      list.reverse(rest)
      |> list.map(fn(f) {
        string.drop_start(f, 1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(utils.unsafe_int_parse)
      })
      as "Expected at least two fields"
    let buttons = list.reverse(buttons)
    Machine(light_diagram:, buttons:, joltages:)
  })
}

fn min_presses_pt_1(light_diagram: Int, buttons: List(Int), presses: Int) -> Int {
  case
    list.combinations(buttons, presses)
    |> list.any(fn(buttons) {
      list.reduce(buttons, int.bitwise_exclusive_or) == Ok(light_diagram)
    })
  {
    True -> presses
    False -> min_presses_pt_1(light_diagram, buttons, presses + 1)
  }
}

fn indexes_to_bitwise_int(l: List(Int)) -> Int {
  list.fold(l, 0, fn(acc, i) {
    int.bitwise_shift_left(1, i) |> int.bitwise_or(acc)
  })
}

pub fn pt_1(machines: List(Machine)) -> Int {
  list.map(machines, fn(m) {
    min_presses_pt_1(
      indexes_to_bitwise_int(m.light_diagram),
      list.map(m.buttons, indexes_to_bitwise_int),
      1,
    )
  })
  |> int.sum
}

const inf = 999_999_999_999_999

pub fn min_presses_pt_2(
  joltages: List(Int),
  button_map: Dict(List(Bool), List(Int)),
  parity_map: Dict(List(Int), List(List(Bool))),
) -> Int {
  use <- bool.guard(list.all(joltages, fn(x) { x == 0 }), return: 0)
  use <- bool.guard(list.any(joltages, fn(x) { x < 0 }), return: inf)
  list.map(joltages, fn(x) { x % 2 })
  |> dict.get(parity_map, _)
  |> result.unwrap([])
  |> list.fold(inf, fn(min, buttons_to_press) {
    let assert Ok(joltage_drops) = dict.get(button_map, buttons_to_press)
    let next_joltages =
      list.zip(joltages, joltage_drops) |> list.map(fn(p) { { p.0 - p.1 } / 2 })
    int.min(
      min,
      list.count(buttons_to_press, function.identity)
        + 2
        * min_presses_pt_2(next_joltages, button_map, parity_map),
    )
  })
}

fn button_combinations(n: Int) -> List(List(Bool)) {
  do_button_combinations(n, [[]])
}

fn do_button_combinations(n: Int, acc: List(List(Bool))) -> List(List(Bool)) {
  case n {
    0 -> acc
    _ ->
      do_button_combinations(
        n - 1,
        list.append(
          list.map(acc, list.prepend(_, False)),
          list.map(acc, list.prepend(_, True)),
        ),
      )
  }
}

pub fn pt_2(machines: List(Machine)) -> Int {
  list.map(machines, fn(m) {
    let #(button_map, parity_map) =
      button_combinations(list.length(m.buttons))
      |> list.fold(#(dict.new(), dict.new()), fn(acc, buttons_to_press) {
        let #(button_map, parity_map) = acc
        let zipped_buttons = list.zip(m.buttons, buttons_to_press)
        let joltages_count =
          list.index_map(m.joltages, fn(_, i) {
            list.count(zipped_buttons, fn(p) { p.1 && list.contains(p.0, i) })
          })
        let joltages_parity = list.map(joltages_count, fn(i) { i % 2 })
        let button_map =
          dict.insert(button_map, buttons_to_press, joltages_count)
        let parity_map =
          dict.upsert(parity_map, joltages_parity, fn(v) {
            option.unwrap(v, []) |> list.prepend(buttons_to_press)
          })
        #(button_map, parity_map)
      })
    min_presses_pt_2(m.joltages, button_map, parity_map)
  })
  |> int.sum
}
