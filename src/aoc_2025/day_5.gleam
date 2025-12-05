import aoc/utils
import gleam/int
import gleam/list
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
  let assert Ok(#(start, end)) = string.split_once(input, "\n\n")
    as "Expected two blocks in input"
  let fresh_id_ranges =
    utils.parsed_lines(start, fn(line) {
      let assert Ok(#(start, end)) = string.split_once(line, "-")
        as { "Invalid range \"" <> line <> "\"" }
      let assert Ok(start) = int.parse(start)
        as { "Invalid ID \"" <> start <> "\"" }
      let assert Ok(end) = int.parse(end) as { "Invalid ID \"" <> end <> "\"" }
      IdRange(start:, end:)
    })
  let available_ids = utils.parsed_lines(end, utils.unsafe_int_parse)
  Inventory(fresh_id_ranges:, available_ids:)
}

pub fn pt_1(inventory: Inventory) {
  list.count(inventory.available_ids, fn(id) {
    list.any(inventory.fresh_id_ranges, fn(id_range) {
      id >= id_range.start && id <= id_range.end
    })
  })
}

fn split_range(
  id_ranges: List(IdRange),
  existing_id_range: IdRange,
) -> List(IdRange) {
  do_split_range(id_ranges, existing_id_range, [])
}

fn do_split_range(
  id_ranges: List(IdRange),
  existing_id_range: IdRange,
  acc: List(IdRange),
) -> List(IdRange) {
  case id_ranges {
    [] -> acc
    [IdRange(start:, end:) as id_range, ..id_ranges]
      if existing_id_range.end < start || existing_id_range.start > end
    -> do_split_range(id_ranges, existing_id_range, [id_range, ..acc])
    [IdRange(start:, end:), ..id_ranges]
      if existing_id_range.start <= start && existing_id_range.end >= end
    -> do_split_range(id_ranges, existing_id_range, acc)
    [IdRange(start:, end:), ..id_ranges]
      if existing_id_range.start > start && existing_id_range.end < end
    ->
      do_split_range(id_ranges, existing_id_range, [
        IdRange(start:, end: existing_id_range.start - 1),
        IdRange(start: existing_id_range.end + 1, end:),
        ..acc
      ])
    [IdRange(start:, end:), ..id_ranges]
      if existing_id_range.start <= start && existing_id_range.end < end
    ->
      do_split_range(id_ranges, existing_id_range, [
        IdRange(start: existing_id_range.end + 1, end:),
        ..acc
      ])
    [IdRange(start:, end:), ..id_ranges]
      if existing_id_range.start > start && existing_id_range.end >= end
    ->
      do_split_range(id_ranges, existing_id_range, [
        IdRange(start:, end: existing_id_range.start - 1),
        ..acc
      ])
    [id_range, ..id_ranges] ->
      do_split_range(id_ranges, existing_id_range, [id_range, ..acc])
  }
}

pub fn pt_2(inventory: Inventory) {
  list.fold(inventory.fresh_id_ranges, #([], 0), fn(acc, id_range) {
    #(
      [id_range, ..acc.0],
      list.fold(acc.0, [id_range], split_range)
        |> list.fold(acc.1, fn(acc, id_range) {
          acc + id_range.end - id_range.start + 1
        }),
    )
  }).1
}
