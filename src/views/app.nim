import npeg
import jsconsole
import jsffi
import json
import asyncjs

import nclearseam
import nclearseam/util
import nclearseam/fetchutil
import dom
import nclearseam/registry

import ../data/group
import ../requests/groups

import ./groups as view_groups
import ./threads as view_threads

var window {.importc, nodecl.}: JsObject

type
  AppRouteEnum = enum
    AppIndex
    AppGroupThreads

  AppRoute = ref object
    hash:       string
    route:      AppRouteEnum
    group_name: string

  AppData* = ref object
    route:   AppRoute
    groups:  Groups
    threads: AppThreads

let route_parser = peg("hash", route: AppRoute):
  hash       <- ?"#" * ( group | index )
  group      <- "/group/" * >group_name * ?"/":
    route.route = AppGroupThreads
    route.group_name = $1
  index      <- ?"/":
    route.route = AppIndex
  group_name <- +( 1 - {'/'})

proc route(hash: string): AppRoute =
  result = AppRoute(hash: hash)
  if not route_parser.match(hash, result).ok:
    return AppRoute(route: AppIndex)

var App*: Component[AppData]

components.declare(App, fetchTemplate("views/app.html", "template", css = true)) do(node: dom.Node) -> Component[AppData]:
  return compile(AppData, node) do(c: MatchConfig[AppData,AppData]):

    # Compute routes
    c.match(c.access->route).refresh do(ev: RefreshEvent[AppRoute]):
      if ev.init:
        proc updateHash() =
          ev.set(route($window.location.hash.to(cstring)))
        window.addEventListener("hashchange", updateHash)
        updateHash()

    # debug
    c.match(".hash", c.access->route->hash).refresh(setText(string))

    # Mount group list
    c.match(".groups") do(app: auto):
      app.mount(GroupsComponent, app.access->groups)

    # Mount group threads
    c.match(".threads") do(app: auto):
      app.refresh_before(updateSet(dataPath("route"))) do(ev: RefreshEvent[AppData]):
        if ev.data.route.route != AppGroupThreads:
          ev.skip = true
          cast[dom.Element](ev.node).classList.add("hidden")
        else:
          ev.skip = false
          (ev->threads->group).set(ev.data.route.group_name)
          cast[Element](ev.node).classList.remove("hidden")
      app.mount(ThreadsComponent, app.access->threads)
