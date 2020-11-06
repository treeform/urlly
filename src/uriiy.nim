## Parses URIs and URLs
##
##  The following are two example URIs and their component parts:
##        foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose
##        \_/   \___/ \_____/ \_________/ \__/\_________/ \_________/ \__/
##         |      |       |       |        |       |          |         |
##      scheme username password hostname port   path       query fragment
##

import strutils

type
  Uri* = ref object
    scheme*, username*, password*: string
    hostname*, port*, path*, fragment*: string
    query*: seq[(string, string)]

proc `[]`*(query: seq[(string, string)], key: string): string =
  ## Get a key out of uri.query.
  ## Use a for loop to get multiple keys.
  for (k, v) in query:
    if k == key:
      return v

proc `[]=`*(query: var seq[(string, string)], key, value: string) =
  ## Sets a key in the uri.query. If key is not there appends a
  ## new key-value pair at the end.
  for pair in query.mitems:
    if pair[0] == key:
      pair[1] = value
      return
  query.add((key, value))

func encodeUrlComponent*(s: string): string =
  ## Takes a string and encodes it in the URI format.
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

func decodeUrlComponent*(s: string): string =
  ## Takes a string and decodes it from the URI format.
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

proc parseUri*(s: string): Uri =
  ## Parses a URI or a URL into the Uri object.
  var s = s
  var uri = Uri()

  let hasFragment = s.rfind('#')
  if hasFragment != -1:
    uri.fragment = s[hasFragment + 1 .. ^1]
    s = s[0 .. hasFragment - 1]

  let hasSearch = s.rfind('?')
  if hasSearch != -1:
    let search = s[hasSearch + 1 .. ^1]
    s = s[0 .. hasSearch - 1]

    for pairStr in search.split('&'):
      let pair = pairStr.split('=', 1)
      let kv =
        if pair.len == 2:
          (decodeUrlComponent(pair[0]), decodeUrlComponent(pair[1]))
        elif pair.len == 1:
          (decodeUrlComponent(pair[0]), "")
        else:
          ("", "")
      uri.query.add(kv)

  let hasScheme = s.find("://")
  if hasScheme != -1:
    uri.scheme = s[0 .. hasScheme - 1]
    s = s[hasScheme + 3 .. ^1]

  let hasLogin = s.find('@')
  if hasLogin != -1:
    let login = s[0 .. hasLogin - 1]
    let hasPassword = login.find(':')
    if hasPassword != -1:
      uri.username = login[0 .. hasPassword - 1]
      uri.password = login[hasPassword + 1 .. ^1]
    else:
      uri.username = login
    s = s[hasLogin + 1 .. ^1]

  let hasPath = s.find('/')
  if hasPath != -1:
    uri.path = s[hasPath .. ^1]
    s = s[0 .. hasPath - 1]

  let hasPort = s.find(':')
  if hasPort != -1:
    uri.port = s[hasPort + 1 .. ^1]
    s = s[0 .. hasPort - 1]

  uri.hostname = s
  return uri

proc host*(uri: Uri): string =
  ## Returns Host and port part of the URI as a string.
  return uri.host & ":" & uri.port

proc search*(uri: Uri): string =
  ## Returns the search part of the URI as a string.
  for i, pair in uri.query:
    if i > 0:
      result.add '&'
    result.add encodeUrlComponent(pair[0])
    result.add '='
    result.add encodeUrlComponent(pair[1])

proc authority*(uri: Uri): string =
  ## Returns the authority part of URI as a string.
  if uri.username.len > 0:
    result.add uri.username
    if uri.password.len > 0:
      result.add ':'
      result.add uri.password
    result.add '@'
  if uri.hostname.len > 0:
    result.add uri.hostname
  if uri.port.len > 0:
    result.add ':'
    result.add uri.port

proc `$`*(uri: Uri): string =
  ## Turns Uri into a string. Preserves query string param ordering.
  if uri.scheme.len > 0:
    result.add uri.scheme
    result.add "://"
  result.add uri.authority
  if uri.path.len > 0:
    if uri.path[0] != '/':
      result.add '/'
    result.add uri.path
  if uri.query.len > 0:
    result.add '?'
    result.add uri.search
  if uri.fragment.len > 0:
    result.add '#'
    result.add uri.fragment
