import aoc/utils
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> Dict(String, List(String)) {
  utils.parsed_lines(input, fn(line) {
    let assert Ok(#(name, outputs)) = string.split_once(line, ": ")
    let outputs = string.split(outputs, " ")
    #(name, outputs)
  })
  |> dict.from_list
}

fn num_paths(
  devices: Dict(String, List(String)),
  cache: Dict(#(String, String), Int),
  from: String,
  to: String,
) -> #(Int, Dict(#(String, String), Int)) {
  case dict.get(cache, #(from, to)) {
    Ok(n) -> #(n, cache)
    Error(Nil) -> {
      case from == to {
        True -> #(1, cache)
        False -> {
          let #(sum, cache) =
            dict.get(devices, from)
            |> result.unwrap([])
            |> list.fold(#(0, cache), fn(acc, from) {
              let #(n, cache) = acc
              let #(m, cache) = num_paths(devices, cache, from, to)
              #(n + m, cache)
            })
          #(sum, dict.insert(cache, #(from, to), sum))
        }
      }
    }
  }
}

pub fn pt_1(devices: Dict(String, List(String))) -> Int {
  num_paths(devices, dict.new(), "you", "out").0
}

pub fn pt_2(devices: Dict(String, List(String))) -> Int {
  num_paths(devices, dict.new(), "svr", "fft").0
  * num_paths(devices, dict.new(), "fft", "dac").0
  * num_paths(devices, dict.new(), "dac", "out").0
}
