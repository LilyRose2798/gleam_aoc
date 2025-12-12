import aoc/utils
import gleam/bool
import gleam/dict.{type Dict}
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

fn add_ones(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> add_ones(int.bitwise_and(n, n - 1), acc + 1)
  }
}

pub fn min_presses_pt_2(
  joltages: List(Int),
  joltage_drop_map: Dict(Int, List(Int)),
  joltage_parity_map: Dict(Int, List(Int)),
) -> Result(Int, Nil) {
  use <- bool.guard(list.all(joltages, fn(x) { x == 0 }), return: Ok(0))
  use <- bool.guard(list.any(joltages, fn(x) { x < 0 }), return: Error(Nil))
  list.fold(joltages, 0, fn(acc, x) { 2 * acc + x % 2 })
  |> dict.get(joltage_parity_map, _)
  |> result.unwrap([])
  |> list.fold(Error(Nil), fn(min, button_combination) {
    let assert Ok(joltage_drops) =
      dict.get(joltage_drop_map, button_combination)
      as "Invalid button combination"
    case
      list.zip(joltages, joltage_drops)
      |> list.map(fn(p) { { p.0 - p.1 } / 2 })
      |> min_presses_pt_2(joltage_drop_map, joltage_parity_map)
    {
      Ok(new_min) -> {
        let new_min = add_ones(button_combination, 2 * new_min)
        case min {
          Ok(cur_min) if cur_min < new_min -> min
          _ -> Ok(new_min)
        }
      }
      Error(Nil) -> min
    }
  })
}

pub fn pt_2(machines: List(Machine)) -> Int {
  list.map(machines, fn(m) {
    let #(joltage_drop_map, joltage_parity_map) =
      list.range(0, int.bitwise_shift_left(1, list.length(m.buttons)) - 1)
      |> list.fold(#(dict.new(), dict.new()), fn(acc, button_combination) {
        let #(joltage_drop_map, joltage_parity_map) = acc
        let joltages_count =
          list.index_map(m.joltages, fn(_, i) {
            list.index_fold(m.buttons, 0, fn(acc, b, j) {
              case
                int.bitwise_shift_left(1, j)
                |> int.bitwise_and(button_combination)
                != 0
                && list.contains(b, i)
              {
                True -> acc + 1
                False -> acc
              }
            })
          })
        #(
          dict.insert(joltage_drop_map, button_combination, joltages_count),
          dict.upsert(
            joltage_parity_map,
            list.fold(joltages_count, 0, fn(acc, i) { 2 * acc + i % 2 }),
            fn(v) { option.unwrap(v, []) |> list.prepend(button_combination) },
          ),
        )
      })
    let assert Ok(min) =
      min_presses_pt_2(m.joltages, joltage_drop_map, joltage_parity_map)
      as "No solution found for machine"
    min
  })
  |> int.sum
}
