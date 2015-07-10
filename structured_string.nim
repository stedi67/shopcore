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

macro StructuredString(name: string{lit}, definition: string{lit}): stmt {.immediate.} =
  var
    low = 0
    high= 0
  echo definition
  result = newStmtList()
  result.add(parseStmt("type $1 = string" % name.strVal))
  for item in split(definition.strVal, ','):
    let newItem = replace(item, " ")
    let key_value = split(newItem, ':')
    let fieldName = key_value[0]
    let fieldLen = parseInt(key_value[1])
    high = high + fieldLen
    result.add(parseStmt("proc $#(base:$#): string = result = base[$#..$#]" % [fieldName, name.strVal, $low, $(high-1)]))
    low = low + fieldLen
  result.add(parseStmt(newFuncText % [name.strVal, name.strVal.capitalize, $high]))

let acdef = """
product_id:4,
version:2,
channel:2,
right:2,
required_product:4,
rop:2,
delivery:2,
num_instances:1,
serial_number_type:1,
language:2,
customer_group_discount:2,
license_dependent_discount:2
"""
StructuredString("SoftwareArticleCode", "a:2")

when isMainModule:
  StructuredString("test", 10, "a:5, b:5")

  var foo = newTest("aaaaabbbbb")

  echo "running assetions"
  assert foo.a == "aaaaa"
  assert foo.b == "bbbbb"
