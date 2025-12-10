import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import gleam_community/maths
import shellout

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
    |> result.unwrap(yielder.empty())
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

pub fn pt_2(machines: List(Machine)) {
  list.map(machines, fn(m) {
    let formula =
      [
        "(set-logic LIA)",
        "(set-option :produce-models true)",
        list.index_map(m.buttons, fn(_, i) {
          "(declare-const x"
          <> int.to_string(i)
          <> " Int) (assert (>= x"
          <> int.to_string(i)
          <> " 0))"
        })
          |> string.join(" "),
        list.map(dict.to_list(m.joltage_requirements), fn(p) {
          let #(i, v) = p
          "(assert (= "
          <> case
            list.index_map(m.buttons, fn(b, i) { #(i, b) })
            |> list.filter(fn(p) { set.contains(p.1, i) })
            |> list.map(pair.first)
          {
            [] -> "0"
            [i] -> "x" <> int.to_string(i)
            is ->
              "(+ "
              <> list.map(is, fn(i) { "x" <> int.to_string(i) })
              |> string.join(" ")
              <> ")"
          }
          <> " "
          <> int.to_string(v)
          <> "))"
        })
          |> string.join(" "),
        "(minimize (+ "
          <> list.index_map(m.buttons, fn(_, i) { "x" <> int.to_string(i) })
        |> string.join(" ")
          <> "))",
        "(check-sat)",
        "(get-objectives)",
        "(exit)",
      ]
      |> string.join(" ")
    let assert Ok(output) =
      shellout.command(
        "sh",
        with: ["-euc", "echo '" <> formula <> "' | z3 -in"],
        in: ".",
        opt: [],
      )
      as "Z3 command failed"
    let assert [_, " " <> n, ..] = string.split(output, ")")
      as { "Unexpected Z3 output: " <> output }
    let assert Ok(n) = int.parse(n) as { "Expected int, got \"" <> n <> "\"" }
    n
  })
  |> int.sum
}
