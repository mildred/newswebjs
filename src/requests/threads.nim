import asyncjs, jsffi
import json, strformat
import ../data/thread

var window {.importc, nodecl.}: JsObject

proc request_threads*(group: string): Future[Threads] {.async.} =
  let res  = await window.fetch(&"/group/{group}/index.json").to(Future[JsObject])
  let text = await res.text().to(Future[JsObject])
  let json = $text.to(cstring)
  result = parseJson(json).to(Threads)

