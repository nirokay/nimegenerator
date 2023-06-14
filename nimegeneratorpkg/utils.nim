import std/[random, tables]

proc randomFrom*[T](sequence: seq[T]): T =
    let ran: int = rand(sequence.len() - 1)
    return sequence[ran]

proc randomFrom*[T, Z](table: Table[T, Z]): Z =
    let ran: int = rand(table.len())
    var count: int
    for i, v in table:
        if count == ran: return v
        count.inc()
