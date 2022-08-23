## Parses URLs and URLs
##
##  The following are two example URLs and their component parts::
##
##       https://admin:hunter1@example.com:8042/over/there?name=ferret#nose
##        \_/   \___/ \_____/ \_________/ \__/\_________/ \_________/ \__/
##         |      |       |       |        |       |          |         |
##       scheme username password hostname port   path[s]    query fragment
##

import strutils

type
  Url* = ref object
    scheme*, username*, password*: string
    hostname*, port*, fragment*: string
    paths*: seq[string]
    query*: seq[(string, string)]

func `[]`*(query: seq[(string, string)], key: string): string =
  ## Get a key out of url.query.
  ## Use a for loop to get multiple keys.
  for (k, v) in query:
    if k == key:
      return v

func `[]=`*(query: var seq[(string, string)], key, value: string) =
  ## Sets a key in the url.query. If key is not there appends a
  ## new key-value pair at the end.
  for pair in query.mitems:
    if pair[0] == key:
      pair[1] = value
      return
  query.add((key, value))

func contains*(query: var seq[(string, string)], key: string): bool =
  ## Returns true if key is in the url.query.
  ## `"name" in url.query` or `"name" notin url.query`
  for pair in query.mitems:
    if pair[0] == key:
      return true

func encodeQueryComponent*(s: string): string =
  ## Takes a string and encodes it in the x-www-form-urlencoded format.
  result = newStringOfCap(s.len)
  for c in s:
    case c:
      of ' ':
        result.add '+'
      of 'a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_', '~':
        result.add(c)
      else:
        result.add '%'
        result.add toHex(ord(c), 2)

func decodeQueryComponent*(s: string): string =
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

func encodeUrlComponent*(s: string): string =
  ## Takes a string and encodes it in the URL format.
  result = newStringOfCap(s.len)
  for c in s:
    case c:
      of 'a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_', '~', '+':
        result.add(c)
      else:
        result.add '%'
        result.add toHex(ord(c), 2)

func decodeUrlComponent*(s: string): string =
  ## Takes a string and decodes it from the URL format.
  result = newStringOfCap(s.len)
  var i = 0
  while i < s.len:
    if s[i] == '%':
      result.add chr(fromHex[uint8](s[i+1 .. i+2]))
      i += 2
    else:
      result.add s[i]
    inc i

func parseSearch*(search: string): seq[(string, string)] =
  ## Parses the search part into strings pairs
  ## "name=&age&legs=4" -> @[("name", ""), ("age", ""), ("legs", "4")]
  for pairStr in search.split('&'):
    let pair = pairStr.split('=', 1)
    let kv =
      if pair.len == 2:
        (decodeQueryComponent(pair[0]), decodeQueryComponent(pair[1]))
      elif pair.len == 1:
        (decodeQueryComponent(pair[0]), "")
      else:
        ("", "")
    result.add(kv)

func parseUrl*(s: string): Url =
  ## Parses a URL or a URL into the Url object.
  var s = s
  var url = Url()

  let hasFragment = s.rfind('#')
  if hasFragment != -1:
    url.fragment = decodeUrlComponent(s[hasFragment + 1 .. ^1])
    s = s[0 .. hasFragment - 1]

  let hasSearch = s.rfind('?')
  if hasSearch != -1:
    let search = s[hasSearch + 1 .. ^1]
    s = s[0 .. hasSearch - 1]
    url.query = parseSearch(search)

  let hasScheme = s.find("://")
  if hasScheme != -1:
    url.scheme = s[0 .. hasScheme - 1]
    s = s[hasScheme + 3 .. ^1]

  let hasLogin = s.find('@')
  if hasLogin != -1:
    let login = s[0 .. hasLogin - 1]
    let hasPassword = login.find(':')
    if hasPassword != -1:
      url.username = login[0 .. hasPassword - 1]
      url.password = login[hasPassword + 1 .. ^1]
    else:
      url.username = login
    s = s[hasLogin + 1 .. ^1]

  let hasPath = s.find('/')
  if hasPath != -1:
    for part in s[hasPath + 1 .. ^1].split('/'):
      url.paths.add(decodeUrlComponent(part))
    s = s[0 .. hasPath - 1]

  let hasPort = s.find(':')
  if hasPort != -1:
    url.port = s[hasPort + 1 .. ^1]
    s = s[0 .. hasPort - 1]

  if hasSearch == -1 and ("&" in s) or ("=" in s):
    # Probably search without ?
    url.query = parseSearch(s)
    s = ""

  url.hostname = s
  return url

func host*(url: Url): string =
  ## Returns hostname and port part of the URL as a string.
  ## Example: "example.com:8042"
  return url.hostname & ":" & url.port

func search*(url: Url): string =
  ## Returns the search part of the URL as a string.
  ## Example: "name=ferret&age=12&legs=4"
  for i, pair in url.query:
    if i > 0:
      result.add '&'
    result.add encodeQueryComponent(pair[0])
    result.add '='
    result.add encodeQueryComponent(pair[1])

func path*(url: Url): string =
  ## Returns paths combine into single path.
  ## @["foo", "bar"] -> "/foo/bar"
  if url.paths.len > 0:
    for part in url.paths:
      result.add '/'
      result.add encodeUrlComponent(part)

func authority*(url: Url): string =
  ## Returns the authority part of URL as a string.
  ## Example: "admin:hunter1@example.com:8042"
  if url.username.len > 0:
    result.add url.username
    if url.password.len > 0:
      result.add ':'
      result.add url.password
    result.add '@'
  if url.hostname.len > 0:
    result.add url.hostname
  if url.port.len > 0:
    result.add ':'
    result.add url.port

func `$`*(url: Url): string =
  ## Turns Url into a string. Preserves query string param ordering.
  if url.scheme.len > 0:
    result.add url.scheme
    result.add "://"
  result.add url.authority
  result.add url.path
  if url.query.len > 0:
    result.add '?'
    result.add url.search
  if url.fragment.len > 0:
    result.add '#'
    result.add encodeUrlComponent(url.fragment)
