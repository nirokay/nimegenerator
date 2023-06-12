## Main module to generate random words
## ====================================
## 
## This module houses procedures that the enduser will be able to call
## themselves.
## 

import std/[random, strutils]
import ./globals, ./letters


# -----------------------------------------------------------------------------
# Private procs:
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Public procs:
# -----------------------------------------------------------------------------

proc generateWord*(): string =
    ## Generates a random word
    result.capitalizeAscii()

proc generateWords*(amount: Positive): seq[string] =
    ## Generates multiple random words
    for i in 1 .. int amount:
        result.add(generateWord())

proc generateWordCustomRule*(rule: Probability): string =
    let backupCurrentRule: Probability = probability
    probability = rule

    result = generateWord()

    probability = backupCurrentRule

proc generateWordsCustomRule*(amount: Positive, rule: Probability): seq[string] =
    let backupCurrentRule: Probability = probability
    probability = rule
    
    for i in 1.. int amount:
        result.add(generateWord())

    probability = backupCurrentRule
