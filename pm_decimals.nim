#!/usr/bin/env nimdebug

# Poor mans Decimals
# Do some restricted set of decimal operations with 64 bit ints.
# At some point, it might be better to use Rationals for implementation

import
  strutils

type
  Sign = enum
    positive, negative
  Precision = int8
  Decimal = tuple[value: int64, prec: Precision, sign: Sign]

proc reverse(s: string): string =
  result = ""
  for i in countdown(high(s), 0):
    result.add s[i]

proc toString(x: Decimal): string =
  result = ""
  let
    (num, prec, sign) = x
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
  if result[0] == '.':
    result = "0" & result
  if sign == negative:
    result = "-" & result

proc `$`*(x: Decimal): string =
  return x.toString


iterator digits(number: string): int =
  for c in number:
    if c in {'0'..'9'}:
      yield ord(c) - ord('0')

proc newDecimal*(description: string): Decimal =
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
  result = val

proc to_precision*(x: Decimal, prec: Precision): Decimal =
  let factors = [1, 10, 100, 1000, 10_000, 100_000, 1_000_000, 10_000_000]
  let m = x.prec - prec
  let factor = factors[abs(m)]
  let new_value = if m > 0: x.value div factor
                      else: x.value * factor
  result = (new_value, prec, x.sign)

proc `+`*(a, b:Decimal): Decimal =
  let prec = max(a.prec, b.prec)
  let new_a = a.to_precision(prec)
  let new_b = b.to_precision(prec)
  let a_v:int64 = if a.sign == negative: - new_a.value
                             else: new_a.value
  let b_v:int64 = if b.sign == negative: - new_b.value
                             else: new_b.value
  let c_v = a_v.int64 + b_v.int64
  let c_sign = if c_v < 0: negative
                     else: positive
  result = (c_v, prec, c_sign)

proc `-`*(a:Decimal): Decimal =
  let sign = if a.sign == positive: negative
                                 else: positive
  result = (a.value, a.prec, sign)

proc `-`*(a, b:Decimal): Decimal =
  result = a + (-b)

proc `*`*[T](a: T, b:Decimal): Decimal =
  if a == 0:
    result = newDecimal("0")
  else:
    result = b
    var i = abs(a) - 1
    while i > 0:
      result = result + b
      i -= 1
    if a < 0:
      result.value = -1 * result.value

proc `==`*(a, b: Decimal): bool =
  result = a.value == b.value and a.prec == b.prec and a.sign == b.sign

when isMainModule:
  echo "running assetions"
  assert($newDecimal("0.01") == "0.01")
  assert($newDecimal("1.00") == "1.00")
  assert($newDecimal("10.24") == "10.24")
  assert($newDecimal("-1.0") == "-1.0")
  assert($newDecimal("2.") == "2.")
  let a = to_precision((100.int64, 0.Precision, positive), 1)
  let b = (1000.int64, 1.Precision, positive)
  assert($a == $b)
  assert($a == "100.0")
  assert((newDecimal("0.12") + newDecimal("1.32")) == newDecimal("1.44"))
  assert((newDecimal("0.120") + newDecimal("1.32")) != newDecimal("1.44"))
  let c = -2 * newDecimal("0.1")
  echo ($c)
  assert((2 * newDecimal("0.1")) == newDecimal("0.2"))
  # fixme next
  assert((-2 * newDecimal("0.1")) == newDecimal("-0.2"))
