import std/[strutils, strformat, tables, random, sets, options]
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
    ## Generates a substring from a letter object.
    ## 
    ## Substrings can be:
    ## 
    ## * formables (e.g. 'e': *"er", "el"*)
    ## * the actual letter#
    ## 
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
    ## Generates substrings for a word with a set amount of cicles.
    var
        currentString: string
        currentLetter: Letter = getRandomLetter()
        previousLetter: Letter
    
    result.add(currentLetter.getWordSubstringFromLetter())
    for i in 0 .. cicles:
        previousLetter = result[^1][^1].getLetterFromChar()
        currentLetter = previousLetter.getNextLetter()

        # Override current letter with vowel, if it exceeded maximum consonants:
        # TODO (looks very inefficient, please optimize it later)
        if rules.maxCharsWithoutVowel.isSome():
            let maxChars: int = rules.maxCharsWithoutVowel.get()
            if currentString.len() > maxChars: break
            for vowel, _ in cachedVowels:
                break
            # Force vowel:
            currentLetter = cachedVowels.randomFrom()

        result.add(currentLetter.getWordSubstringFromLetter())
        currentString.add(result[^1])


proc generateWordWithCicles*(cicles: Positive): string =
    ## Shortcut to `generateWordSubstringsWithCicles().join()`.
    return generateWordSubstringsWithCicles(cicles).join()


# -----------------------------------------------------------------------------
# Populate dictionary (~ default config):
# -----------------------------------------------------------------------------

proc addToDictionary*(letters: seq[Letter]) =
    ## Adds new letters to the dictionary.
    ## 
    ## If a letter already exists, it will be overridden (a warning is printed to stdout).
    ## 
    for l in letters:
        if l.letter.int() == 0:
            echo &"Letter `{$l}` invalid, skipped..."
            continue

        if dictionary.hasKey(l.letter):
            echo &"Duplicate letter {l.letter}... overriding original."

        # Add to dictionary:
        dictionary[l.letter] = l

        # Cache vowels:
        if l.vowel:
            cachedVowels[l.letter] = l


addToDictionary @[
    L(
        letter: 'a',
        vowel: true,
        formables: @["al", "am", "an", "alt"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['a'],
            never: @[]
        )
    ),
    L(
        letter: 'b',
        formables: @["br", "bo", "ba"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'c',
        formables: @["cr", "ca", "co", "ch", "ce", "ck"],
        followed: F(
            always: @[],
            often: @['h', 'k'],
            rarely: @['v', 'w'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'd',
        formables: @["da", "dre", "do"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'w'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'e',
        vowel: true,
        formables: @["el", "er"],
        followed: F(
            always: @[],
            often: @['i', 'r', 'l'],
            rarely: @['e', 'a'],
            never: @[]
        )
    ),
    L(
        letter: 'f',
        formables: @["fi", "fin", "fil", "fa", "fas", "far", "fat", "fol"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'w'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'g',
        formables: @["go", "gol", "gr"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'h',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v'],
            never: @['z', 'x', 'q', 'h']
        )
    ),
    L(
        letter: 'i',
        vowel: true,
        formables: @["ie", "ied", "ing", "ingen"],
        followed: F(
            always: @[],
            often: @['e'],
            rarely: @[],
            never: @['i']
        )
    ),
    L(
        letter: 'j',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v','j', 's', 'k', 'l', 'h', 'g', 'f', 'n', 'p', 'w'],
            never: @['z', 'q', 'x']
        )
    ),
    L(
        letter: 'k',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v'],
            never: @['z', 'q', 'x']
        )
    ),
    L(
        letter: 'l',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'l', 'w'],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'm',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'w', 'm', 'n'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'n',
        formables: @[],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'w', 'n', 'm'],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'o',
        vowel: true,
        formables: @["ov", "on", "or", "ot", "oc", "ock"]
    ),
    L(
        letter: 'p',
        formables: @[],
        followed: F(
            always: @[],
            often: @['e', 'a'],
            rarely: @['v', 'n', 'p', 'm'],
            never: @['z', 'x', 'q']
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
        formables: @["ra", "rac", "rat", "ran", "re", "rel", "ri", "ris", "rist"],
        followed: F(
            always: @[],
            often: @['a', 'e', 'i', 'o', 'u'],
            rarely: @['r', 'v', 'w', 't'],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 's',
        formables: @["sh", "sch", "ss"],
        followed: F(
            always: @[],
            often: @['c', 'h', 's'],
            rarely: @['q'],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 't',
        formables: @["tic", "tac"],  # hehe, tic-tac
        followed: F(
            always: @[],
            often: @['r'],
            rarely: @['q', 'v', 'l'],
            never: @['z', 'x']
        )
    ),
    L(
        letter: 'u',
        vowel: true,
        formables: @["un", "und"]
    ),
    L(
        letter: 'v',
        formables: @["vy", "vi"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['v', 'w'],
            never: @['x', 'z', 'q']
        )
    ),
    L(
        letter: 'w',
        formables: @["wo", "wi", "wing"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @['w'],
            never: @['z', 'x', 'q']
        )
    ),
    L(
        letter: 'x',
        formables: @["xy", "xi"],
        followed: F(
            always: @[],
            often: @['u', 'i'],
            rarely: @['x'],
            never: @['z', 'q']
        )
    ),
    L(
        letter: 'y',
        formables: @[]
    ),
    L(
        letter: 'z',
        formables: @["ze", "zer"],
        followed: F(
            always: @[],
            often: @[],
            rarely: @[],
            never: @['x', 'z']
        )
    )
]


