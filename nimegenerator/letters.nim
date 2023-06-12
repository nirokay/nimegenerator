import std/[strformat, tables, random, sets]
import ./globals, ./utils

type
    Followed* = object
        always*, often*, rarely*, never*: seq[char]

    Letter* = object
        letter*: char
        vowel*: bool
        followed*: Followed
        formables*: seq[string]

    Operation* = enum
        doProbableLetter, doFormable



# -----------------------------------------------------------------------------
# Dictionary:
# -----------------------------------------------------------------------------

type
    F = Followed
    L = Letter

var
    dictionary*: Table[char, Letter]
    cachedDefaultLetters: Table[char, seq[Letter]]



# -----------------------------------------------------------------------------
# Letter procs:
# -----------------------------------------------------------------------------

proc decideWhatNextOperation(): Operation =
    let ran: float = rand(1.0)
    if ran >= probability.formables: return doFormable
    else: return doProbableLetter

proc getRandomLetter*(): Letter =
    let ran: int = rand(dictionary.len() - 1)
    var counter: int
    for i, letter in dictionary:
        if counter == ran: return letter
        counter.inc()


proc getAllRemainingLetters(letter: Letter): seq[Letter] =
    # Return cache for this letter, if available: (because ...
    if cachedDefaultLetters.hasKey(letter.letter):
        return cachedDefaultLetters[letter.letter]

    # ... this is very expensive):
    var bannedLetters: HashSet[char] = letter.followed.always.toHashSet() + letter.followed.often.toHashSet() +
        letter.followed.rarely.toHashSet() + letter.followed.never.toHashSet()

    for c, l in dictionary:
        if c in bannedLetters: continue
        result.add(l)
    cachedDefaultLetters[letter.letter] = result

proc getNextLetter*(curr: Letter): Letter =
    let ran: float = rand(1.0)
    var letterPool: seq[Letter]

    if ran in probability.rarelyFloor .. probability.oftenCeil:
        letterPool = curr.getAllRemainingLetters()
        return letterPool.randomFrom()

proc getNextLetter*(curr: char): Letter =
    var letter: Letter
    if dictionary.hasKey(curr):
        letter = dictionary[curr]
    else:
        letter = getRandomLetter()

    return letter.getNextLetter()

proc getNextLetter*(word: string): Letter =
    if word.len() == 0: return getRandomLetter()
    word[^1].getNextLetter()



# -----------------------------------------------------------------------------
# Populate dictionary (~ default config):
# -----------------------------------------------------------------------------

proc addToDictionary*(letters: seq[Letter]) =
    for l in letters:
        if l.letter.int() == 0:
            echo &"Letter `{$l}` invalid, skipped..."
            continue

        if dictionary.hasKey(l.letter):
            echo &"Duplicate letter {l.letter}... overriding original."
        
        dictionary[l.letter] = l


addToDictionary @[
    L(
        letter: 'a',
        vowel: true,
        formables: @["al", "am", "an", "alt"]
    ),
    L(
        letter: 'b',
        formables: @["br"]
    ),
    L(
        letter: 'c',
        formables: @["cr", "ca", "co", "ch", "ce", "ck"],
        followed: F(
            always: @[],
            often: @['h', 'k'],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'd',
        formables: @["da", "dre", "do"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'e',
        vowel: true,
        formables: @["el"]
    ),
    L(
        letter: 'f',
        formables: @["fi", "fin", "fil", "fa", "fas", "far", "fat", "fol"]
    ),
    L(
        letter: 'g',
        formables: @["go", "gol", "gr"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'h',
        formables: @[]
    ),
    L(
        letter: 'i',
        vowel: true,
        formables: @["ie", "ied", "ing", "ingen"]
    ),
    L(
        letter: 'j',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['s', 'k', 'l', 'h', 'g', 'f', 'n', 'p', 'w'],
            never: @['z', 'q', 'x']
        )
    ),
    L(
        letter: 'k',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'q', 'x']
        )
    ),
    L(
        letter: 'l',
        formables: @[]
    ),
    L(
        letter: 'm',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z']
        )
    ),
    L(
        letter: 'n',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z']
        )
    ),
    L(
        letter: 'o',
        vowel: true,
        formables: @["ov", "on", "or"]
    ),
    L(
        letter: 'p',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z']
        )
    ),
    L(
        letter: 'q',
        formables: @["qu", "que"],
        followed: F(
            always: @['u']
        )
    ),
    L(
        letter: 'r',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 's',
        formables: @["sh", "sch", "ss"],
        followed: F(
            always: @[],
            often: @['c', 'h', 's'],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 't',
        formables: @["tic"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'u',
        vowel: true,
        formables: @[]
    ),
    L(
        letter: 'v',
        formables: @["vy", "vi"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['x', 'z', 'q']
        )
    ),
    L(
        letter: 'w',
        formables: @["wo", "wi", "wing"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'x',
        formables: @["xy", "xi"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['z', 'q']
        )
    ),
    L(
        letter: 'y',
        formables: @[]
    ),
    L(
        letter: 'z',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['x']
        )
    )
]


