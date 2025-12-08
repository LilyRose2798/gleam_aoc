import aoc/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string

pub type Box {
  Box(x: Int, y: Int, z: Int)
}

pub fn parse(input: String) -> List(Box) {
  utils.parsed_lines(input, fn(line) {
    let assert [x, y, z] =
      string.split(line, ",") |> list.map(utils.unsafe_int_parse)
    Box(x:, y:, z:)
  })
}

type Connection {
  Connection(from: Box, to: Box)
}

type State {
  State(
    available_connections: List(Connection),
    connections: Set(Connection),
    circuits: List(Set(Box)),
  )
}

fn distance_squared(c: Connection) -> Int {
  let dx = c.from.x - c.to.x
  let dy = c.from.y - c.to.y
  let dz = c.from.z - c.to.z
  dx * dx + dy * dy + dz * dz
}

fn make_state(boxes: List(Box)) -> State {
  let available_connections =
    list.combination_pairs(boxes)
    |> list.map(fn(p) { Connection(from: p.0, to: p.1) })
    |> list.sort(fn(a, b) {
      int.compare(distance_squared(a), distance_squared(b))
    })
  let connections = set.new()
  let circuits = list.map(boxes, set.insert(set.new(), _))
  State(available_connections:, connections:, circuits:)
}

fn connect_closest(state: State) -> #(Connection, State) {
  let State(available_connections:, connections:, ..) = state
  let assert [connection, ..available_connections] = available_connections
    as "Expected at least one pair of boxes"
  let state = State(..state, available_connections:)
  case set.contains(connections, connection) {
    True -> connect_closest(state)
    False -> {
      let connections = set.insert(connections, connection)
      let circuits = case
        list.partition(state.circuits, fn(c) {
          set.contains(c, connection.from) || set.contains(c, connection.to)
        })
      {
        #([c], circuits) -> [c, ..circuits]
        #([c, d], circuits) -> [set.union(c, d), ..circuits]
        _ -> panic as "Expected to find one or two circuits"
      }
      let state = State(..state, connections:, circuits:)
      #(connection, state)
    }
  }
}

fn do_pt_1(state: State, to_connect: Int) -> Int {
  case to_connect {
    0 ->
      list.map(state.circuits, set.size)
      |> list.sort(order.reverse(int.compare))
      |> list.take(3)
      |> int.product
    _ -> do_pt_1(connect_closest(state).1, to_connect - 1)
  }
}

pub fn pt_1(boxes: List(Box)) -> Int {
  do_pt_1(make_state(boxes), 1000)
}

fn do_pt_2(state: State) -> Int {
  case connect_closest(state) {
    #(Connection(from:, to:), State(circuits: [_], ..)) -> from.x * to.x
    #(_, state) -> do_pt_2(state)
  }
}

pub fn pt_2(boxes: List(Box)) -> Int {
  do_pt_2(make_state(boxes))
}
