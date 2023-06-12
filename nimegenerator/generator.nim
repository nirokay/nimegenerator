## Main module to generate random words
## ====================================
## 
## This module houses procedures that the enduser will be able to call
## themselves.
## 

import std/[os, strutils, random]
import ./globals, ./letters


# -----------------------------------------------------------------------------
# Modify global ruleset:
# -----------------------------------------------------------------------------

proc setCustomGlobalRules*(newRules: GenerationRules) =
    ## Change global rule set.
    rules = newRules


proc loadCustomConfigFromFile*(filepath: string) =
    if filepath == "":
        echo "Did not receive filepath. Using default config."
        return
    
    if not filepath.fileExists():
        echo "Invalid filepath received. Using default config."
        return

    # TODO add functionality

# -----------------------------------------------------------------------------
# Public generation procs:
# -----------------------------------------------------------------------------

proc generateWord*(): string =
    ## Generates a random word
    let cicles: int = abs(rand(rules.generationCicles.max) + rules.generationCicles.min)
    result = generateWordWithCicles(cicles)
    result = result.capitalizeAscii()

proc generateWords*(amount: Positive): seq[string] =
    ## Generates multiple random words
    for i in 1 .. int amount:
        result.add(generateWord())

proc generateWordCustomRule*(tempRules: GenerationRules): string =
    ## Generates a random word with temporary rule set
    let backupCurrentRule: GenerationRules = rules
    rules = tempRules

    result = generateWord()

    rules = backupCurrentRule

proc generateWordsCustomRule*(amount: Positive, tempRules: GenerationRules): seq[string] =
    ## Generates multiple random words with temporary rule set
    let backupCurrentRule: GenerationRules = rules
    rules = tempRules

    for i in 1.. int amount:
        result.add(generateWord())

    rules = backupCurrentRule
