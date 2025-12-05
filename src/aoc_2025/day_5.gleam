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

pub fn pt_1(inventory: Inventory) {
  list.count(inventory.available_ids, fn(id) {
    list.any(inventory.fresh_id_ranges, fn(id_range) {
      id >= id_range.start && id <= id_range.end
    })
  })
}

pub fn pt_2(inventory: Inventory) {
  list.fold(inventory.fresh_id_ranges, #([], 0), fn(acc, id_range) {
    #(
      [id_range, ..acc.0],
      list.fold(acc.0, [id_range], fn(acc, existing_id_range) {
        list.fold(acc, [], fn(acc, id_range) {
          case id_range {
            IdRange(start:, end:)
              if existing_id_range.end < start || existing_id_range.start > end
            -> [id_range, ..acc]
            IdRange(start:, end:)
              if existing_id_range.start <= start
              && existing_id_range.end >= end
            -> acc
            IdRange(start:, end:)
              if existing_id_range.start > start && existing_id_range.end < end
            -> [
              IdRange(start:, end: existing_id_range.start - 1),
              IdRange(start: existing_id_range.end + 1, end:),
              ..acc
            ]
            IdRange(start:, end:)
              if existing_id_range.start <= start && existing_id_range.end < end
            -> [IdRange(start: existing_id_range.end + 1, end:), ..acc]
            IdRange(start:, end:)
              if existing_id_range.start > start && existing_id_range.end >= end
            -> [IdRange(start:, end: existing_id_range.start - 1), ..acc]
            _ -> [id_range, ..acc]
          }
        })
      })
        |> list.fold(acc.1, fn(acc, id_range) {
          acc + id_range.end - id_range.start + 1
        }),
    )
  }).1
}
