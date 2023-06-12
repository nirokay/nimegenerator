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

import std/[random, strutils]
randomize()

import nimegenerator/[globals, generator]
export globals, generator

when isMainModule:
    let
        amount: Positive = 25
        tabIn: int = len($int amount)

    # Generate words and print them out:
    for i in 1..amount:
        echo align($i, tabIn, ' ') & ": " & generateWord()

