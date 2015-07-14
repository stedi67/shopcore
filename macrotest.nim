#!/usr/bin/env nimdebug
#
import macros, strutils

macro StructuredString(name: string, e: stmt): stmt {.immediate.} =
  echo name
  echo repr(e)
  discard

when isMainModule:
  StructuredString(Foo):
    a:3
    b:2
