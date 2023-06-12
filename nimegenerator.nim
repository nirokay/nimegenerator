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

import std/[random]
randomize()

import nimegenerator/[generator]
export generator

when isMainModule:
    echo "Loaded as executable!"


