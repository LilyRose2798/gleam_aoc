import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import shellout
import simplifile
import temporary

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

fn indexes_to_bitwise_int(s: Set(Int)) -> Int {
  set.fold(s, 0, fn(acc, i) {
    int.bitwise_shift_left(1, i) |> int.bitwise_or(acc)
  })
}

pub fn pt_1(machines: List(Machine)) {
  list.map(machines, fn(m) {
    min_presses_pt_1(
      indexes_to_bitwise_int(m.light_diagram),
      list.map(m.buttons, indexes_to_bitwise_int),
      1,
    )
  })
  |> int.sum
}

fn var(i: Int) -> String {
  " x" <> int.to_string(i)
}

pub fn pt_2(machines: List(Machine)) {
  list.map(machines, fn(m) {
    let formula =
      "(set-logic LIA) (set-option :produce-models true)"
      <> list.index_fold(m.buttons, "", fn(acc, _, i) {
        let v = var(i)
        acc <> " (declare-const" <> v <> " Int) (assert (>=" <> v <> " 0))"
      })
      <> list.fold(dict.to_list(m.joltage_requirements), "", fn(acc, p) {
        let vs =
          list.index_fold(m.buttons, "", fn(acc, b, i) {
            case set.contains(b, p.0) {
              True -> acc <> var(i)
              False -> acc
            }
          })
        acc <> " (assert (= (+" <> vs <> ") " <> int.to_string(p.1) <> "))"
      })
      <> " (minimize (+"
      <> list.index_fold(m.buttons, "", fn(acc, _, i) { acc <> var(i) })
      <> ")) (check-sat) (get-objectives) (exit)"
    let assert Ok(res) =
      temporary.create(temporary.file(), fn(file_path) {
        let assert Ok(_) = simplifile.write(formula, to: file_path)
        shellout.command("z3", with: [file_path], in: ".", opt: [])
      })
      as "Failed to create temporary file"
    let output = case res {
      Ok(output) -> output
      Error(#(i, output)) ->
        panic as {
          "Z3 command failed with exit status "
          <> int.to_string(i)
          <> " and output: "
          <> output
        }
    }
    let assert [_, " " <> n, ..] = string.split(output, ")")
      as { "Unexpected Z3 output: " <> output }
    let assert Ok(n) = int.parse(n) as { "Expected int, got \"" <> n <> "\"" }
    n
  })
  |> int.sum
}
