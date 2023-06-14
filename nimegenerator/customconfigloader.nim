## Module for loading custom config files in form of json
## ======================================================
## 
## Example config file:
## 
## https://github.com/nirokay/nimegenerator/blob/master/examples/custom_config_example.json
## 
## Custom config files are kinda barebones, each entry overrides the already existing/default stuff.
## 

import std/[os, json, options]
import ./globals, ./letters

type
    JsonFollowed* = tuple
        always, often, rarely, never: Option[seq[string]]

    JsonLetter* = object
        letter*: string
        vowel*: Option[bool]
        followed*: Option[JsonFollowed]
        formables*: Option[seq[string]]

    ConfigFile* = object
        rules*: Option[GenerationRules]
        dictionary*: Option[seq[JsonLetter]]

proc addFields(followed: var seq[char], field: Option[seq[string]]) =
    if field.isNone(): return
    let f: seq[string] = field.get()
    for str in f:
        followed.add(str[0])


# Horrible proc, do not lookj at it please:
proc getNewLettersFrom(dic: var seq[Letter], newLetters: seq[JsonLetter]) =
    for l in newLetters:
        try:
            var letter: Letter = Letter(
                letter: l.letter[0]
            )
            if l.vowel.isSome():
                letter.vowel = l.vowel.get()
            if l.formables.isSome():
                letter.formables = l.formables.get()
            
            if l.followed.isSome():
                # I really have no excuses for this one:
                let f: JsonFollowed = l.followed.get()
                var followed: Followed
                followed.always.addFields(f.always)
                followed.often.addFields(f.often)
                followed.rarely.addFields(f.rarely)
                followed.never.addFields(f.never)
                letter.followed = followed
            
            dic.add(letter)

        except CatchableError:
            # Should not happen normally:
            echo "Got invalid letter: `" & $l & "`! Skipping..."
            continue



proc loadCustomConfigFromFile*(filepath: string) =
    if filepath == "":
        echo "Did not receive filepath. Using default config."
        return
    
    if not filepath.fileExists():
        echo "Invalid filepath received. Using default config."
        return

    # Parse json file:
    var jsonObj: JsonNode
    try:
        jsonObj = filepath.readFile().parseJson()
    except JsonParsingError:
        echo "Invalid json file, failed to parse. Using default config."
        return
    except IOError:
        echo "Could not read file. Using default config."
        return

    # Read ConfigFile object:
    var newConfig: ConfigFile
    try:
        newConfig = jsonObj.to(ConfigFile)
    except CatchableError:
        echo "Could not convert json to ConfigFile object. Using default config."
        return

    # Rule set update:
    var customRules: GenerationRules = defaultGenerationRules
    if newConfig.rules.isSome():
        customRules = newConfig.rules.get()
    rules = customRules

    # Dictionary update:
    var dictionaryAdditions: seq[Letter]
    if newConfig.dictionary.isSome():
        dictionaryAdditions.getNewLettersFrom(newConfig.dictionary.get())
    addToDictionary(dictionaryAdditions)

