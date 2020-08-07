import jsconsole
import asyncjs

import nclearseam
import dom
import nclearseam/registry

import ./views/app

proc main() {.async discardable.} =
  await components.init()
  App.clone().attach(document.body, nil, AppData())

when isMainModule:
  main()
