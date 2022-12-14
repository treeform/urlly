import std/typetraits, std/strutils

type HttpHeaders* = distinct seq[(string, string)]

converter toBase*(headers: var HttpHeaders): var seq[(string, string)] =
  headers.distinctBase

converter toBase*(headers: HttpHeaders): seq[(string, string)] =
  headers.distinctBase

proc contains*(headers: var HttpHeaders, key: string): bool =
  ## Checks if there is at least one header for the key. Not case sensitive.
  for (k, v) in headers:
    if cmpIgnoreCase(k, key) == 0:
      return true

proc `[]`*(headers: var HttpHeaders, key: string): string =
  ## Returns the first header value the key. Not case sensitive.
  for (k, v) in headers:
    if cmpIgnoreCase(k, key) == 0:
      return v

proc `[]=`*(headers: var HttpHeaders, key, value: string) =
  ## Adds a new header if the key is not already present. If the key is already
  ## present this overrides the first header value for the key.
  ## Not case sensitive.
  for i, (k, v) in headers:
    if cmpIgnoreCase(k, key) == 0:
      headers.toBase[i][1] = value
      return
  headers.add((key, value))

proc emptyHttpHeaders*(): HttpHeaders =
  discard
