#!/usr/bin/env nimdebug

# Poor mans Decimals
# Do some restricted set of decimal operations with 64 bit ints.
# The layout is: 60 bit number, 1 bit sign and 3 bit precision

import
  strutils

type
  Decimal = int64

proc reverse(s: string): string =
  result = ""
  for i in countdown(high(s), 0):
    result.add s[i]

proc toString(x: Decimal): string =
  result = ""
  let prec = 0b111 and x
  let sign = 0b1000 and x
  let num = x div 16 
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
  if sign > 0:
    result = "-" & result


iterator digits(number: string): int =
  for c in number: 
    if c in {'0'..'9'}:
      yield ord(c) - ord('0')

proc toDecimal(description: string): Decimal =
  result = 0
  var sign = if description[0] == '-': 0b1000
                                 else: 0

  let rev = description.reverse
  let prec = rev.find(".")
  var multiplier = 1
  for num in digits(rev):
    result = result + num * multiplier
    multiplier = multiplier * 10
  result = result * 16 # left shift of 3 bits
  result = result + sign
  result = result + prec

when isMainModule:
  echo "running assetions"
  assert((toString toDecimal("0.01")) == "0.01")
  assert((toString toDecimal("1.00")) == "1.00")
  assert((toString toDecimal("10.24")) == "10.24")
  assert((toString toDecimal("-1.0")) == "-1.0")
  assert((toString toDecimal("2.")) == "2.")
