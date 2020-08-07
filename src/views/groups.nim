import strformat
import nclearseam
import nclearseam/util
import nclearseam/fetchutil
import dom
import nclearseam/registry
import jsconsole
import asyncjs, jsffi
import json

import ../data/group
import ../requests/groups

var GroupsComponent*: ComponentInterface[Groups]

proc iterGroups(grps: Groups): ProcIter[Group] =
  seqIterator(grps)

proc init(ev: RefreshEvent[Groups]): Future[void] {.async.} =
  let groups: Groups = await request_groups()
  ev.set(groups)

let setTextString: proc (node: Node, text: string){.closure.} = setText(string)

components.declare(GroupsComponent, fetchTemplate("views/groups.html", "template", css = true)) do(node: dom.Node) -> Component[Groups]:
  return compile(Groups, node) do(c: MatchConfig[Groups,Groups]):
    c.refresh do(ev: RefreshEvent[Groups]):
      if ev.init: discard init(ev)
    c.iter("li", iterGroups) do(group: auto):
      group.match("a", group.access->name) do(a: auto):
        a.refresh(setText(string))
        a.refresh do(ev: RefreshEvent[string]):
          ev.node.setAttribute("href", &"#/group/{ev.data}")
      group.match(".description", group.access->description).refresh(setText(string))
