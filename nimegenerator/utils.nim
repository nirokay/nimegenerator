import std/[random]

proc randomFrom*[T](sequence: seq[T]): T =
    let ran: int = rand(sequence.len() - 1)
    return sequence[ran]

