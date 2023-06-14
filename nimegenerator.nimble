# Package

version       = "1.0.0"
author        = "nirokay"
description   = "Random name/word generator."
license       = "GPL-3.0-only"
installExt    = @["nim"]
bin           = @["nimegenerator"]
skipDirs      = @["docs", "tests", "examples"]
skipFiles     = @["update_docs.sh"]


# Dependencies

requires "nim >= 1.6.10"
