import gleam/dict.{type Dict}
import gleam/float
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn normalise_newlines(input: String) -> String {
  string.replace(input, "\r\n", "\n")
}

pub fn lines(input: String) -> List(String) {
  let input = normalise_newlines(input)
  case string.ends_with(input, "\n") {
    True -> string.drop_end(input, 1)
    False -> input
  }
  |> string.split("\n")
}

pub fn parsed_lines(input: String, with fun: fn(String) -> a) -> List(a) {
  lines(input) |> list.map(fun)
}

pub fn fields_by(input: String, by separator: String) -> List(String) {
  string.split(input, separator)
  |> list.map(string.trim)
  |> list.filter(fn(f) { f != "" })
}

pub fn fields(input: String) -> List(String) {
  fields_by(input, " ")
}

pub fn line_fields_by(input: String, by separator: String) -> List(List(String)) {
  lines(input) |> list.map(fields_by(_, separator))
}

pub fn line_fields(input: String) -> List(List(String)) {
  lines(input) |> list.map(fields)
}

pub fn parsed_fields_by(
  input: String,
  by separator: String,
  with fun: fn(String) -> a,
) -> List(a) {
  fields_by(input, separator) |> list.map(fun)
}

pub fn parsed_fields(input: String, with fun: fn(String) -> a) -> List(a) {
  fields(input) |> list.map(fun)
}

pub fn parsed_line_fields_by(
  input: String,
  by separator: String,
  with fun: fn(String) -> a,
) -> List(List(a)) {
  lines(input) |> list.map(parsed_fields_by(_, separator, fun))
}

pub fn parsed_line_fields(
  input: String,
  with fun: fn(String) -> a,
) -> List(List(a)) {
  lines(input) |> list.map(parsed_fields(_, fun))
}

pub fn blocks(input: String) -> List(String) {
  normalise_newlines(input) |> string.split("\n\n")
}

pub fn parsed_blocks(input: String, with fun: fn(String) -> a) -> List(a) {
  blocks(input) |> list.map(fun)
}

pub fn block_lines(input: String) -> List(List(String)) {
  blocks(input) |> list.map(lines)
}

pub fn parsed_block_lines(
  input: String,
  with parse_fn: fn(String) -> a,
) -> List(List(a)) {
  block_lines(input) |> list.map(list.map(_, parse_fn))
}

pub fn folded_block_lines(
  input: String,
  from initial: acc,
  with fun: fn(acc, String) -> acc,
) -> List(acc) {
  block_lines(input) |> list.map(list.fold(_, initial, fun))
}

pub fn unsafe_reduced_block_lines(
  input: String,
  with fun: fn(String, String) -> String,
) -> List(String) {
  block_lines(input) |> list.map(unsafe_reduce(_, fun))
}

pub fn filter_not(list: List(a), discarding f: fn(a) -> Bool) {
  list.filter(list, fn(x) { !f(x) })
}

pub fn unsafe_unwrap(x: Result(a, e)) -> a {
  case x {
    Ok(x) -> x
    Error(_) -> panic
  }
}

pub fn unsafe_expect(x: Result(a, e), throw message: String) -> a {
  case x {
    Ok(x) -> x
    Error(_) -> panic as message
  }
}

pub fn unsafe_reduce(list: List(a), with fun: fn(a, a) -> a) -> a {
  case list.reduce(list, fun) {
    Ok(x) -> x
    Error(Nil) -> panic as "Expected non-empty list"
  }
}

pub fn unsafe_int_parse(input: String) -> Int {
  case int.parse(input) {
    Ok(x) -> x
    Error(Nil) -> panic as { "Invalid int value \"" <> input <> "\"" }
  }
}

pub fn unsafe_int_base_parse(input: String, base: Int) -> Int {
  case base < 2 || base > 36 {
    True -> panic as { "Invalid int base " <> int.to_string(base) }
    False ->
      case int.base_parse(input, base) {
        Ok(x) -> x
        Error(Nil) -> panic as { "Invalid int value \"" <> input <> "\"" }
      }
  }
}

pub fn unsafe_float_parse(input: String) -> Float {
  case float.parse(input) {
    Ok(x) -> x
    Error(Nil) -> panic as { "Invalid float value \"" <> input <> "\"" }
  }
}

pub fn int_power(base: Int, of exponent: Int) -> Int {
  case base {
    _ if exponent < 0 -> 0
    0 | 1 | -1 -> base
    2 | -2 -> int.bitwise_shift_left(base, exponent - 1)
    _ -> do_int_power(base, exponent, 1)
  }
}

fn do_int_power(base: Int, exponent: Int, acc: Int) -> Int {
  case exponent {
    0 -> acc
    _ -> do_int_power(base, exponent - 1, acc * base)
  }
}

pub fn int_ceiling_divide(dividend: Int, divisor: Int) {
  -{ dividend / -divisor }
}

pub fn unsafe_int_power(base: Int, of exponent: Float) -> Float {
  case int.power(base, exponent) {
    Ok(x) -> x
    Error(Nil) ->
      panic as {
        "Invalid base or exponent "
        <> int.to_string(base)
        <> "^"
        <> float.to_string(exponent)
      }
  }
}

pub fn unsafe_float_power(base: Float, of exponent: Float) -> Float {
  case float.power(base, exponent) {
    Ok(x) -> x
    Error(Nil) ->
      panic as {
        "Invalid base or exponent "
        <> float.to_string(base)
        <> "^"
        <> float.to_string(exponent)
      }
  }
}

pub fn unsafe_dict_get(dict: Dict(a, b), key: a) -> b {
  case dict.get(dict, key) {
    Ok(x) -> x
    Error(Nil) -> panic as "Missing key in dict"
  }
}

pub fn dict_get_or_default(dict: Dict(a, b), key: a, default: b) -> b {
  dict.get(dict, key) |> result.unwrap(default)
}

pub fn unsafe_list_first(list: List(a)) -> a {
  case list.first(list) {
    Ok(x) -> x
    Error(Nil) -> panic as "Expected non-empty list"
  }
}

pub fn unsafe_list_last(list: List(a)) -> a {
  case list.last(list) {
    Ok(x) -> x
    Error(Nil) -> panic as "Expected non-empty list"
  }
}

pub fn unsafe_find(list: List(a), with fun: fn(a) -> Bool) -> a {
  case list.find(list, fun) {
    Ok(x) -> x
    Error(Nil) -> panic as "Expected to find element in list"
  }
}

pub fn unsafe_key_find(list: List(#(a, b)), with key: a) -> b {
  case list.key_find(list, key) {
    Ok(x) -> x
    Error(Nil) -> panic as "Expected to find element in list"
  }
}

pub fn unsafe_list_to_pair(list: List(a)) -> #(a, a) {
  let assert [a, b] = list as "Expected list with two elements"
  #(a, b)
}

pub fn counts_by(list: List(a), by fun: fn(a) -> b) -> Dict(b, Int) {
  list.group(list, fun) |> dict.map_values(fn(_, xs) { list.length(xs) })
}

pub fn counts(list: List(a)) -> Dict(a, Int) {
  counts_by(list, function.identity)
}

pub fn sum_by(list: List(a), by fun: fn(a) -> Int) -> Int {
  list.map(list, fun) |> int.sum
}

pub fn product_by(list: List(a), by fun: fn(a) -> Int) -> Int {
  list.map(list, fun) |> int.product
}

pub fn int_distance(a: Int, b: Int) -> Int {
  int.absolute_value(a - b)
}

pub fn float_distance(a: Float, b: Float) -> Float {
  float.absolute_value(a -. b)
}

pub fn tap(x: a, with fun: fn(a) -> b) -> a {
  fun(x)
  x
}
