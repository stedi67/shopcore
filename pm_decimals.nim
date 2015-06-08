#!/usr/bin/env nimdebug

# Poor mans Decimals
# Do some restricted set of decimal operations with 64 bit ints.
# At some point, it might be better to use Rationals for implementation

import
  strutils

type
  Precision = int8
  Decimal = tuple[value: int64, prec: Precision]

proc reverse(s: string): string =
  result = ""
  for i in countdown(high(s), 0):
    result.add s[i]

iterator digits(number: string): int =
  for c in number:
    if c in {'0'..'9'}:
      yield ord(c) - ord('0')

proc newDecimal*(description: string): Decimal =
  var value = 0.int64
  let fac = if description[0] == '-': -1
                                 else: 1

  let rev = description.reverse
  let prec = rev.find(".").int8
  var multiplier = 1
  for num in digits(rev):
    value = value + num * multiplier
    multiplier = multiplier * 10
  let val = (fac*value, prec)
  result = val

proc `<`*(a, b: Decimal): bool =
  return a.value < b.value

proc `<`*[T](a: Decimal, b: T): bool =
  return a.value < b

proc `>=`*[T,S](a: T, b: S): bool =
  return not (a < b)

proc toString(x: Decimal): string =
  result = ""
  let (num, prec) = x
  var s = $abs(num)
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
  if num < 0:
    result = "-" & result

proc `$`*(x: Decimal): string =
  return x.toString


proc to_precision*(x: Decimal, prec: Precision): Decimal =
  let factors = [1, 10, 100, 1000, 10_000, 100_000, 1_000_000, 10_000_000]
  let m = x.prec - prec
  let i = abs(m)
  var new_value = 0.int64
  if m > 0:
    let val = x.value div factors[i-1]
    if (val - 5) div 10 != val div 10: # we would need to round down
        new_value = val div 10
    else: # rounding up
        let diff = val - (val div 10) * 10
        new_value = (val + diff) div 10
  else:
      new_value = x.value * factors[i]
  result = (new_value, prec)

proc `+`*(a, b:Decimal): Decimal =
  let prec = max(a.prec, b.prec)
  let new_a = a.to_precision(prec)
  let new_b = b.to_precision(prec)
  result = (new_a.value + new_b.value, prec)

proc `-`*(a:Decimal): Decimal =
  result = (-a.value, a.prec)

proc `-`*(a, b:Decimal): Decimal =
  result = a + (-b)

proc `*`*[T](a: T, b:Decimal): Decimal =
  result = (a*b.value, b.prec)

proc `*`*(a, b:Decimal): Decimal =
  result = (a.value*b.value, a.prec + b.prec)

proc `==`*(a, b: Decimal): bool =
  result = a.value == b.value and a.prec == b.prec

when isMainModule:
  echo "running assetions"
  assert($newDecimal("0.1") == "0.1")
  assert($newDecimal("0.01") == "0.01")
  assert($newDecimal("1.00") == "1.00")
  assert($newDecimal("10.24") == "10.24")
  assert($newDecimal("-1.0") == "-1.0")
  assert($newDecimal("2.") == "2.")
  let a = to_precision((100.int64, 0.Precision), 1)
  let b = (1000.int64, 1.Precision)
  assert($a == $b)
  assert($a == "100.0")
  assert((newDecimal("0.12") + newDecimal("1.32")) == newDecimal("1.44"))
  assert((newDecimal("0.120") + newDecimal("1.32")) != newDecimal("1.44"))
  let c = -2 * newDecimal("0.1")
  assert((2 * newDecimal("0.1")) == newDecimal("0.2"))
  # fixme next
  assert((-2 * newDecimal("0.1")) == newDecimal("-0.2"))
  assert(newDecimal("1.005").to_precision(2) == newDecimal("1.01"))
  assert(newDecimal("1.0049").to_precision(2) == newDecimal("1.00"))
  assert($c == "-0.2")
  assert(newDecimal("1.1") > newDecimal("1.0"))
  assert(newDecimal("-1.1") < newDecimal("-1.0"))
  assert(newDecimal("1.1") >= newDecimal("1.0"))
  assert(newDecimal("-1.1") <= newDecimal("-1.0"))
  assert(newDecimal("1.1") >= newDecimal("1.1"))
  assert(newDecimal("1.1") <= newDecimal("1.1"))
  assert((newDecimal("0.12") - newDecimal("1.00")) == newDecimal("-0.88"))
  assert((newDecimal("2.00") * newDecimal("2.00")) == newDecimal("4.0000"))
  assert((newDecimal("100.00") * newDecimal("0.19")) == newDecimal("19.0000"))
