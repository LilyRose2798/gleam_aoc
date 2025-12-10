import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import gleam_community/maths

pub type Machine {
  Machine(
    light_diagram: Set(Int),
    buttons: List(Set(Int)),
    joltage_requirements: Dict(Int, Int),
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
      |> list.index_fold(set.new(), fn(acc, c, i) {
        case c == hash {
          True -> set.insert(acc, i)
          False -> acc
        }
      })
    let assert [joltage_requirements, ..buttons] =
      list.reverse(rest)
      |> list.map(fn(f) {
        string.drop_start(f, 1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(utils.unsafe_int_parse)
      })
      as "Expected at least two fields"
    let buttons = list.reverse(buttons) |> list.map(set.from_list)
    let joltage_requirements =
      list.index_map(joltage_requirements, fn(x, i) { #(i, x) })
      |> dict.from_list
    Machine(light_diagram:, buttons:, joltage_requirements:)
  })
}

fn min_presses_pt_1(
  light_diagram: Set(Int),
  buttons: List(Set(Int)),
  presses: Int,
) -> Int {
  case
    maths.list_combination_with_repetitions(buttons, presses)
    |> utils.unsafe_unwrap
    |> yielder.any(fn(buttons) {
      list.fold(buttons, set.new(), set.symmetric_difference) == light_diagram
    })
  {
    True -> presses
    False -> min_presses_pt_1(light_diagram, buttons, presses + 1)
  }
}

pub fn pt_1(machines: List(Machine)) {
  list.map(machines, fn(m) { min_presses_pt_1(m.light_diagram, m.buttons, 1) })
  |> int.sum
}

fn min_presses_pt_2(
  required_joltage: Dict(Int, Int),
  buttons: List(Dict(Int, Int)),
  presses: Int,
) -> Result(Int, Nil) {
  // echo #("state", required_joltage, "presses", presses)
  let joltage_values = dict.to_list(required_joltage)
  case
    list.all(joltage_values, fn(p) { p.1 == 0 }),
    list.any(joltage_values, fn(p) { p.1 < 0 })
  {
    _, True -> Error(Nil)
    True, _ -> Ok(presses)
    False, _ ->
      case
        list.combination_pairs(joltage_values)
        |> list.find_map(fn(p) {
          case p {
            #(#(i, v), #(j, w)) if v > w ->
              case
                list.filter(buttons, fn(button) {
                  dict.has_key(button, i) && !dict.has_key(button, j)
                })
              {
                [button] -> Ok(button)
                _ -> Error(Nil)
              }
            #(#(i, v), #(j, w)) if v < w ->
              case
                list.filter(buttons, fn(button) {
                  dict.has_key(button, j) && !dict.has_key(button, i)
                })
              {
                [button] -> Ok(button)
                _ -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })
      {
        Ok(button) -> {
          // echo #("button", dict.keys(button))
          min_presses_pt_2(
            dict.combine(required_joltage, button, int.add),
            buttons,
            presses + 1,
          )
        }
        Error(Nil) -> {
          // no easy option to pick
          list.map(buttons, fn(button) {
            dict.combine(required_joltage, button, int.add)
            |> min_presses_pt_2(buttons, presses + 1)
          })
          |> result.values
          |> list.max(order.reverse(int.compare))
        }
      }
  }
}

pub fn pt_2(machines: List(Machine)) {
  list.map(machines, fn(m) {
    min_presses_pt_2(
      m.joltage_requirements,
      list.map(m.buttons, fn(b) {
        set.to_list(b)
        |> list.map(fn(i) { #(i, -1) })
        |> dict.from_list
      }),
      0,
    )
  })
  |> result.values
  |> int.sum
}
