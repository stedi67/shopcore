#!/usr/bin/env nimdebug
#
import macros, strutils

let newFuncText = """
proc new$2(text:string):$1 =
  if text.len != $3:
    var e:ref ValueError
    new(e)
    e.msg = "A new $2 needs to have length $3"
    raise e
  result = $1(text)
"""

macro StructuredString(name: string, deflist: stmt): stmt {.immediate.} =
  var
    low:BiggestInt = 0
    high:BiggestInt = 0
    fieldName: string
    fieldLen: BiggestInt

  result = newStmtList()
  result.add(parseStmt("type $1 = string" % $name))
  for i in 0..deflist.len-1:
    fieldName = $deflist[i][0].ident
    fieldLen = deflist[i][1][0].intVal
    high = high + fieldLen
    result.add(parseStmt("proc $#(base:$#): string = result = base[$#..$#]" % [fieldName, $name, $low, $(high-1)]))
    low = low + fieldLen
  result.add(parseStmt(newFuncText % [$name, ($name).capitalize, $high]))

when isMainModule:
  StructuredString(test):
    a:5
    b:5

  var foo = newTest("aaaaabbbbb")
  echo "running assetions"
  assert foo.a == "aaaaa"
  assert foo.b == "bbbbb"
