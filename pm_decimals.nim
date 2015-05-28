import
  strutils

type
  Decimal = object
    value: int
    prec: Positive

proc reverse(s: string): string =
  result = ""
  for i in countdown(high(s), 0):
    result.add s[i]

proc toString(x: Decimal): string =
  var value_string = intToStr(x.value, x.prec+1).reverse
  result = newString(value_string.len + 1)
  for i in 0..result.len - 1:
    if i < x.prec:
      result[i] = value_string[i]
    elif i == x.prec:
      result[i] = "."[0]
    elif i > x.prec:
      result[i] = value_string[i-1]
  result = result.reverse

when isMainModule:
  assert(toString(Decimal(value:100, prec:2)) == "1.00", "Wrong")
  assert(toString(Decimal(value:1001, prec:2)) == "10.01", "Wrong")
  assert(toString(Decimal(value:1, prec:2)) == "0.01", "Wrong")
