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
const
    version: string = "1.0.0"
    binName: string = "nimegenerator"
    description: string = "Random name/word generator."
    authors: seq[string] = @["nirokay"]
    website: string = "https://github.com/nirokay/nimegenerator"
    docs: string = "https://nirokay.github.io/nim-docs/nimegenerator/nimegenerator.html"

import std/random
randomize()

import nimegeneratorpkg/[globals, generator]
export globals, generator



when isMainModule:
    import std/[os, strutils, strformat, parseopt]

    type Command = object
        longName*, shortName*, desc*: string
        call*: proc(str: string)

    var commands: seq[Command]


    proc helpCommand(_: string) =
        # Print general info:
        echo &"{binName} by {authors.join(\", \")}\n{description}"
        echo &"Website: {website}\nDocs:    {docs}\n"
        # Print all command options:
        var cmdHelp: seq[string]
        for cmd in commands:
            cmdHelp.add(&"-{cmd.shortName} | --{cmd.longName}\n  {cmd.desc}")
        echo cmdHelp.join("\n\n")
        quit(0)
    proc versionCommand(_: string) =
        echo &"{binName} v{version}"
        quit(0)


    commands = @[
        Command(
            longName: "help",
            shortName: "h",
            desc: "Displays this help message.",
            call: helpCommand
        ),
        Command(
            longName: "version",
            shortName: "v",
            desc: "Displays software version.",
            call: versionCommand
        ),
        Command(
            longName: "configfile",
            shortName: "c",
            desc: "Loads config file (only supports json format).",
            call: loadCustomConfigFromFile
        )
    ]

    var
        p = initOptParser(commandLineParams())
        amount: Positive = 10

    for kind, key, value in p.getopt():
        case kind:

        of cmdEnd: break

        of cmdArgument:
            try:
                amount = key.parseInt()
            except CatchableError:
                echo "Could not parse integer. Defaulting to 1..."#

        of cmdLongOption, cmdShortOption:
            for cmd in commands:
                if key == cmd.shortName or key == cmd.longName: cmd.call(value)


    # Generate words and print them out:
    let tabIn: int = len($int amount)
    for i in 1..amount:
        echo align($i, tabIn, ' ') & ": " & generateWord()

