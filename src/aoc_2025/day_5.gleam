import aoc/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type Id =
  Int

pub type IdRange {
  IdRange(start: Id, end: Id)
}

pub type Inventory {
  Inventory(fresh_id_ranges: List(IdRange), available_ids: List(Id))
}

pub fn parse(input: String) -> Inventory {
  let assert Ok(#(fresh_id_ranges, available_ids)) =
    string.split_once(input, "\n\n")
    as "Expected two blocks in input"
  let fresh_id_ranges =
    utils.parsed_lines(fresh_id_ranges, fn(line) {
      let assert Ok(#(start, end)) = string.split_once(line, "-")
        as { "Invalid range \"" <> line <> "\"" }
      let assert Ok(start) = int.parse(start)
        as { "Invalid ID \"" <> start <> "\"" }
      let assert Ok(end) = int.parse(end) as { "Invalid ID \"" <> end <> "\"" }
      IdRange(start:, end:)
    })
  let available_ids = utils.parsed_lines(available_ids, utils.unsafe_int_parse)
  Inventory(fresh_id_ranges:, available_ids:)
}

pub fn pt_1(inventory: Inventory) -> Int {
  list.count(inventory.available_ids, fn(id) {
    list.any(inventory.fresh_id_ranges, fn(id_range) {
      id >= id_range.start && id <= id_range.end
    })
  })
}

fn do_total_ids(id_ranges: List(IdRange), cur_end: Int, total_ids: Int) -> Int {
  case id_ranges {
    [] -> total_ids
    [IdRange(start:, end:), ..id_ranges] if start > cur_end ->
      do_total_ids(id_ranges, end, total_ids + end - start + 1)
    [IdRange(end:, ..), ..id_ranges] if end > cur_end ->
      do_total_ids(id_ranges, end, total_ids + end - cur_end)
    [_, ..id_ranges] -> do_total_ids(id_ranges, cur_end, total_ids)
  }
}

pub fn pt_2(inventory: Inventory) -> Int {
  list.sort(inventory.fresh_id_ranges, fn(a, b) {
    case Nil {
      _ if a.start < b.start -> order.Lt
      _ if a.start > b.start -> order.Gt
      _ -> order.Eq
    }
  })
  |> do_total_ids(0, 0)
}
