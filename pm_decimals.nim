#!/usr/bin/env nimdebug

# Poor mans Decimals
# Do some restricted set of decimal operations with 64 bit ints.
# The layout is: 60 bit number, 1 bit sign and 3 bit precision
# At some point, it might be better to use Rationals for implementation

import
  strutils

type
  Decimal = int64
  Sign = enum
    positive, negative
  Precision = int8
  DecimalAsTuple = tuple[value: int64, prec: Precision, sign: Sign]

proc reverse(s: string): string =
  result = ""
  for i in countdown(high(s), 0):
    result.add s[i]

proc asTuple(x: Decimal): DecimalAsTuple =
  let prec = int8(0b111 and x)
  let sign = Sign((0b1000 and x) div 8)
  let num = x div 16
  result = (num, prec, sign)

proc fromTuple(x: DecimalAsTuple): Decimal =
  let sign = if x.sign == negative: 1.int64
                              else: 0.int64
  result = x.value * 16 + sign * 8 + int64(x.prec)

proc toString(x: Decimal): string =
  result = ""
  let
    (num, prec, sign) = asTuple(x)
  var s = $num
  s = s.reverse
  var k = prec - s.len + 1
  while k>0:
    s.add "0"
    k = k-1

  for i in 0..s.len:
    if i < prec:
      result.add s[i]
    elif i == prec:
      result.add "."
    elif i > prec:
      result.add s[i-1]

  result = result.reverse
  if sign == negative:
    result = "-" & result


iterator digits(number: string): int =
  for c in number: 
    if c in {'0'..'9'}:
      yield ord(c) - ord('0')

proc toDecimal(description: string): Decimal =
  var value = 0.int64
  let sign = if description[0] == '-': negative
                                 else: positive

  let rev = description.reverse
  let prec = rev.find(".").int8
  var multiplier = 1
  for num in digits(rev):
    value = value + num * multiplier
    multiplier = multiplier * 10
  let val = (value, prec, sign)
  result = val.fromTuple

proc `+`(a, b:Decimal): Decimal =
  result = a

when isMainModule:
  echo "running assetions"
  assert((toString toDecimal("0.01")) == "0.01")
  assert((toString toDecimal("1.00")) == "1.00")
  assert((toString toDecimal("10.24")) == "10.24")
  assert((toString toDecimal("-1.0")) == "-1.0")
  assert((toString toDecimal("2.")) == "2.")
  echo toString(toDecimal("0.12") + toDecimal("1.32"))
  assert((toDecimal("0.12") + toDecimal("1.32")) == toDecimal("1.44"))
