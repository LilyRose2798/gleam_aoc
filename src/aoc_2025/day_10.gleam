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

pub fn pt_2(machines: List(Machine)) {
  list.sized_chunk(machines, 50)
  |> list.map(fn(machines) {
    let #(vars, conditions) =
      list.index_fold(machines, #([], ""), fn(acc, m, i) {
        #(
          list.range(0, list.length(m.buttons) - 1)
            |> list.fold(acc.0, fn(acc, j) {
              ["x" <> int.to_string(i) <> "_" <> int.to_string(j), ..acc]
            }),
          dict.fold(m.joltage_requirements, acc.1, fn(acc, k, v) {
            let sum =
              list.index_fold(m.buttons, [], fn(acc, b, j) {
                case set.contains(b, k) {
                  True -> [
                    "x" <> int.to_string(i) <> "_" <> int.to_string(j),
                    ..acc
                  ]
                  False -> acc
                }
              })
              |> string.join(" + ")
            acc <> sum <> " = " <> int.to_string(v) <> " "
          }),
        )
      })
    let vars = list.reverse(vars)
    let formula =
      "Minimize "
      <> string.join(vars, " + ")
      <> " Bounds "
      <> list.map(vars, string.append(_, " >= 0")) |> string.join(" ")
      <> " Subject To "
      <> conditions
      <> "Generals "
      <> string.join(vars, " ")
      <> " End"
    let assert Ok(res) =
      temporary.create(
        temporary.file() |> temporary.with_suffix(".lp"),
        fn(file_path) {
          let assert Ok(_) = simplifile.write(formula, to: file_path)
          shellout.command("scip", with: ["-f", file_path], in: ".", opt: [])
        },
      )
      as "Failed to create temporary file"
    let output = case res {
      Ok(output) -> output
      Error(#(i, output)) ->
        panic as {
          "SCIP command failed with exit status "
          <> int.to_string(i)
          <> " and output: "
          <> output
        }
    }
    let assert Ok(n) =
      string.split(output, "\n")
      |> list.find_map(fn(line) {
        case line {
          "objective value:" <> rest ->
            Ok(string.trim(rest) |> utils.unsafe_int_parse)
          _ -> Error(Nil)
        }
      })
      as { "Unexpected SCIP output: " <> output }
    n
  })
  |> int.sum
}
