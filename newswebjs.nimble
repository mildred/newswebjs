# Package

version       = "0.0.0"
author        = "Mildred Ki'Lya"
description   = "NewsWeb, News web reader based on NimNews server"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["newsweb"]

backend       = "js"

# Dependencies

requires "nim >= 1.2.4"
requires "nclearseam"
requires "npeg"
