import std/[strutils, strformat, tables, random, sets]
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
    cachedVowels*: Table[char, Letter]
    cachedDefaultLetters: Table[char, seq[Letter]]



# -----------------------------------------------------------------------------
# Letter procs:
# -----------------------------------------------------------------------------

proc decideWhatNextOperation(): Operation =
    let ran: float = rand(1.0)
    if ran >= rules.probability.formables: return doFormable
    else: return doProbableLetter

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


proc getRandomLetter*(): Letter =
    ## Returns a random letter.
    let ran: int = rand(dictionary.len() - 1)
    var counter: int
    for i, letter in dictionary:
        if counter == ran: return letter
        counter.inc()

proc getLetterFromChar*(c: char): Letter =
    ## Returns letter from dictionary. Returns a random one, if missing dictionary entry.
    if dictionary.hasKey(c): return dictionary[c]
    return getRandomLetter()


proc getNextLetter*(curr: Letter): Letter =
    ## Returns next Letter object.
    let ran: float = rand(1.0)

    # Get rare or common letters:
    if ran < rules.probability.rarelyFloor and curr.followed.rarely.len() != 0:
        return curr.followed.rarely.randomFrom().getLetterFromChar()

    if ran > rules.probability.oftenCeil and curr.followed.often.len() != 0:
        return curr.followed.often.randomFrom().getLetterFromChar()

    # Get any other except the ones before:
    if ran in rules.probability.rarelyFloor .. rules.probability.oftenCeil:
        return curr.getAllRemainingLetters().randomFrom()

    # Should never happen but who knows...
    return getRandomLetter()

proc getNextLetter*(curr: char): Letter =
    ## Returns next Letter object from a char.
    var letter: Letter
    if dictionary.hasKey(curr):
        letter = dictionary[curr]
    else:
        letter = getRandomLetter()

    return letter.getNextLetter()

proc getNextLetter*(word: string): Letter =
    ## Returns next Letter object from a string.
    if word.len() == 0: return getRandomLetter()
    return word[^1].getNextLetter()


proc getWordSubstringFromLetter*(letter: Letter): string =
    let operation: Operation = block:
        if letter.formables.len() == 0: doProbableLetter
        else: decideWhatNextOperation()

    case operation:
    of doFormable:
        # Add a random formable to string:
        return letter.formables.randomFrom()
    of doProbableLetter:
        # Add letter itself to string:
        return $letter.letter

proc generateWordSubstringsWithCicles*(cicles: Positive): seq[string] =
    var
        currentLetter: Letter = getRandomLetter()
        previousLetter: Letter
    
    result.add(currentLetter.getWordSubstringFromLetter())
    for i in 0 .. cicles:
        previousLetter = result[^1][^1].getLetterFromChar()
        currentLetter = previousLetter.getNextLetter()
        result.add(currentLetter.getWordSubstringFromLetter())



proc generateWordWithCicles*(cicles: Positive): string =
    return generateWordSubstringsWithCicles(cicles).join()


# -----------------------------------------------------------------------------
# Populate dictionary (~ default config):
# -----------------------------------------------------------------------------

proc addToDictionary*(letters: seq[Letter]) =
    ## Adds new letters to the dictionary.
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
        formables: @["br", "bo", "ba"]
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
            never: @['x', 'z']
        )
    )
]


