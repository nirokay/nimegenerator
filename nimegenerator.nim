## Welcome to the NimeGenerator documentation!
## ===========================================
## 
## About
## =====
## 
## NimeGenerator generates random names based on some given rules,
## like for example:
## 
## * which letter commonly follows another
## * commonly found letter patterns (e.g.: "er", "na", "qu", ...)
## 
## 

import std/[os, random, strutils, parseopt]
randomize()

import nimegenerator/[globals, generator]
export globals, generator

proc helpDisplay() =
    # TODO add help info
    echo "NimeGenerator"
    quit(0)


when isMainModule:
    var
        p = initOptParser(commandLineParams())
        amount: Positive = 1

    for kind, key, value in p.getopt():
        case kind:

        of cmdEnd: break

        of cmdArgument:
            try:
                amount = key.parseInt()
            except CatchableError:
                echo "Could not parse integer. Defaulting to 1..."#

        of cmdLongOption, cmdShortOption:
            case key:
            of "help", "h": helpDisplay()
            of "configfile", "c": loadCustomConfigFromFile(value)


    # Generate words and print them out:
    let tabIn: int = len($int amount)
    for i in 1..amount:
        echo align($i, tabIn, ' ') & ": " & generateWord()

