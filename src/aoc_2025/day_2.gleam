import aoc/utils
import gleam/int
import gleam/list
import gleam/string

pub type Tree {
  Node(start: Int, end: Int, left: Tree, right: Tree)
  Leaf
}

fn in_tree(tree: Tree, value: Int) -> Bool {
  case tree {
    Node(start:, left:, ..) if value < start -> in_tree(left, value)
    Node(end:, right:, ..) if value > end -> in_tree(right, value)
    Node(..) -> True
    Leaf -> False
  }
}

fn make_tree(ranges: List(#(Int, Int))) -> Tree {
  case list.split(ranges, list.length(ranges) / 2) {
    #(left, [#(start, end), ..right]) ->
      Node(start:, end:, left: make_tree(left), right: make_tree(right))
    _ -> Leaf
  }
}

pub fn parse(input: String) -> Tree {
  string.split(input, ",")
  |> list.map(fn(range) {
    let assert Ok(#(first, last)) = string.split_once(range, "-")
      as { "Invalid id range \"" <> range <> "\"" }
    #(utils.unsafe_int_parse(first), utils.unsafe_int_parse(last))
  })
  |> list.sort(fn(x, y) { int.compare(x.0, y.0) })
  |> make_tree
}

fn max_id_length(tree: Tree) -> Int {
  case tree {
    Node(end:, right: Leaf, ..) -> int.to_string(end) |> string.length
    Node(right:, ..) -> max_id_length(right)
    Leaf -> panic as "Expected non-empty tree"
  }
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

fn solve(tree: Tree, pt_1: Bool) -> Int {
  let max_id_len = max_id_length(tree)
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
  |> list.filter(in_tree(tree, _))
  |> list.unique
  |> int.sum
}

pub fn pt_1(tree: Tree) -> Int {
  solve(tree, True)
}

pub fn pt_2(tree: Tree) -> Int {
  solve(tree, False)
}
