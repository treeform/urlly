import std/strutils, std/typetraits

type QueryParams* = distinct seq[(string, string)]

converter toBase*(params: var QueryParams): var seq[(string, string)] =
  params.distinctBase

converter toBase*(params: QueryParams): seq[(string, string)] =
  params.distinctBase

proc `[]`*(query: QueryParams, key: string): string =
  ## Get a key out of url.query. Returns an empty string if key is not present.
  ## Use a for loop to get multiple keys.
  for (k, v) in query.toBase:
    if k == key:
      return v

proc `[]=`*(query: var QueryParams, key, value: string) =
  ## Sets the value for the key in url.query. If the key is present, this
  ## appends a new key-value pair to the end.
  for pair in query.mitems:
    if pair[0] == key:
      pair[1] = value
      return
  query.add((key, value))

proc contains*(query: QueryParams, key: string): bool =
  ## Returns true if key is in the url.query.
  ## `"name" in url.query` or `"name" notin url.query`
  for pair in query:
    if pair[0] == key:
      return true

proc emptyQueryParams*(): QueryParams =
  discard

proc add*(query: var QueryParams, params: QueryParams) =
  for (k, v) in params:
    query.add((k, v))

proc encodeQueryComponent*(s: string): string =
  ## Similar to encodeURIComponent, however query parameter spaces should
  ## be +, not %20 like encodeURIComponent would encode them.
  ## The encoded string is in the x-www-form-urlencoded format.
  result = newStringOfCap(s.len)
  for c in s:
    case c:
      of ' ':
        result.add '+'
      of 'a'..'z', 'A'..'Z', '0'..'9',
        '-', '.', '_', '~', '!', '*', '\'', '(', ')':
        result.add(c)
      else:
        result.add '%'
        result.add toHex(ord(c), 2)

proc decodeQueryComponent*(s: string): string =
  ## Takes a string and decodes it from the x-www-form-urlencoded format.
  result = newStringOfCap(s.len)
  var i = 0
  while i < s.len:
    case s[i]:
      of '%':
        result.add chr(fromHex[uint8](s[i+1 .. i+2]))
        i += 2
      of '+':
        result.add ' '
      else:
        result.add s[i]
    inc i

proc `$`*(query: QueryParams): string =
  for i, pair in query:
    if i > 0:
      result.add '&'
    result.add encodeQueryComponent(pair[0])
    result.add '='
    result.add encodeQueryComponent(pair[1])
