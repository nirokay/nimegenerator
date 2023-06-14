# NimeGenerator

nimegenerator is a random name/word generator.

## How it works

A word is constructed letter by letter, substring by substring. Depending on the last letter, a random letter will be chosen to follow it.

Some letters have higher and lower chances to be chosen. This probabillity is for every letter each.

**For example:**

* `e` is rarely followed by `a` or another `e`, but often followed by an `r` or `l`

* `p` is rarely followed by `n`, but often followed by an `e` or `a`

These rules are hardcoded for defaults, but can be overridden with custom config files. Config files are json files and examples can be found in `./examples/`!

## Usage

This is a library-binary hybrid. This means you can build an executable for use in the terminal or import it into your own Nim projects.

### Installation

* nimble: `nimble install nimegenerator` (not yet in repos)

* git: `git clone https://github.com/nirokay/nimegenerator && cd nimegenerator && nimble install`

### Executable

```bash
# Prints 10 random words:
nimegenerator

# Prints 5 random words:
nimegenerator 5

# Help message:
nimegenerator --help
nimegenerator -h

# Version printout:
nimegenerator --version
nimegenerator -v

# Load custom config file and print random words:
nimegenerator --configfile:/path/to/file
nimegenerator -c:/path/to/file
nimegenerator -c:/path/to/file 10
```

### Library

Simply import it like any other module!

```nim
import nimegenerator

echo generateWord()
```

## Documentation

For detailed documentation, please visit the [nim generated docs](https://nirokay.github.io/nim-docs/nimegenerator/nimegenerator)!
