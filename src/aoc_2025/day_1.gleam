import aoc/utils
import gleam/int
import gleam/list

const size = 100

pub fn parse(input: String) -> List(Int) {
  utils.parsed_lines(input, fn(line) {
    case line {
      "L" <> rest -> -utils.unsafe_int_parse(rest)
      "R" <> rest -> utils.unsafe_int_parse(rest)
      _ -> panic as "Invalid rotation"
    }
  })
}

fn calculate_password(rotations: List(Int), with fun: fn(Int, Int, Int) -> Int) {
  list.fold(rotations, #(50, 0), fn(acc, rotation) {
    let #(position, password) = acc
    let assert Ok(new_position) = int.modulo(position + rotation, size)
    #(new_position, password + fun(position, rotation, new_position))
  }).1
}

pub fn pt_1(rotations: List(Int)) -> Int {
  use _, _, new_position <- calculate_password(rotations)
  case new_position {
    0 -> 1
    _ -> 0
  }
}

pub fn pt_2(rotations: List(Int)) -> Int {
  use position, rotation, _ <- calculate_password(rotations)
  case rotation < 0 {
    True -> { size - position } % size - rotation
    False -> position + rotation
  }
  / size
}
