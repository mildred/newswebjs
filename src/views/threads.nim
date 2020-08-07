import strformat
import nclearseam
import nclearseam/util
import nclearseam/fetchutil
import dom
import nclearseam/registry
import jsconsole
import asyncjs, jsffi
import json

import ../data/thread
import ../requests/threads

type AppThreads* = ref object
  group*:       string
  loaded_group: string
  threads*:     seq[Thread]

var ThreadsComponent*: ComponentInterface[AppThreads]
var ThreadComponent*:  ComponentInterface[Thread]

proc init(ev: RefreshEvent[AppThreads]) {.async.} =
  let group = (ev->group).get()
  let threads: Threads = await request_threads(group)
  console.log("threads: %v", threads)
  (ev->threads).set(threads.threads)
  (ev->loaded_group).set(group)

let template_threads = fetchTemplate("views/threads.html", "template.threads", css = true)
components.compile(ThreadsComponent, template_threads) do(c: MatchConfig[AppThreads,AppThreads]):

  # Initialize
  c.refresh_before() do(ev: RefreshEvent[AppThreads]):
    if ev.data.group != ev.data.loaded_group:
      discard init(ev)
    else:
      console.log("Already loaded %v", ev.data.loaded_group)

  c.match(c.access->threads) do(threads: auto):
    threads.iter("li.thread", seqIterator[Thread]) do(thread: auto):
      thread.mount(ThreadComponent)

let template_thread = fetchTemplate("views/threads.html", "template.thread", css = true)
components.compile(ThreadComponent, template_thread) do(c: MatchConfig[Thread,Thread]):

  c.match("a.subject", c.access->article->subject).refresh(setText(string))
  c.match("a.from", c.access->article->from_h).refresh(setText(string))
  c.match(".date", c.access->article->date).refresh(setText(string))

  c.match(c.access->children).iter("li", seqIterator[Thread]) do(thread: auto):
    thread.mount(ThreadComponent)

