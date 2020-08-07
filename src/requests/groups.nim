import asyncjs, jsffi
import json
import ../data/group

var window {.importc, nodecl.}: JsObject

proc request_groups*(): Future[Groups] {.async.} =
  let res  = await window.fetch("/group.json").to(Future[JsObject])
  let text = await res.text().to(Future[JsObject])
  let json = $text.to(cstring)
  result = parseJson(json).to(seq[Group])

