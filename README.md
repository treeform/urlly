# Uriiy (Pronounced Yuri)

URI and URL parsing for Nim for C/JS backends. Similar api to browsers's `window.location`.

Nim's standard library `uri` module does not parse the query string. And Nim's standard library `cgi` module does not work in `js` mode. This module works everywhere and parses everything! Including providing an easy way to work with the query key-value pairs.

```
  foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose
  \_/   \___/ \_____/ \_________/ \__/\_________/ \_________/ \__/
   |      |       |       |        |       |          |         |
scheme username password hostname port   path       query fragment
```

## Using the `parseUri()`.

```nim
let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
let uri = parseUri(test)
uri.scheme == "foo"
uri.username == "admin"
uri.password == "hunter1"
uri.hostname == "example.com"
uri.port == "8042"
uri.authority == "admin:hunter1@example.com:8042"
uri.path == "/over/there"
uri.search == "name=ferret"
uri.query["name"] == "ferret"
uri.fragment == "nose"
$uri == test
```

## Using the `$()`.

You can always turn a `Uri` into a `string` with the `$` function.

```nim
var uri = Uri()
uri.hostname = "example.com"
uri.query["q"] = "foo"
uri.fragment = "heading1"
assert $uri == "example.com?q=foo#heading1"
```

## Using the `query` parameter.

The `Uri.query` is just a sequence of key value pairs (`seq[(string, string)]`). This preserves their order and allows 100% exact reconstruction of the uri string. This also allows you to walk through each pair looking for things you need:

```nim
let uri = parseUri("?name=ferret&age=12&leg=1&leg=2&leg=3&leg=4")

for (k, v) in uri.query:
if k == "leg":
    echo v
```

But for most use cases a special `[]` is provided. This is the most common use of the query.

```nim
uri.query["name"] == "ferret"
```

If the key repeats multiple times only the first one is returned using the `[]` method. Use the for loop method if you need to support multiple keys or preserves special ordering.

```nim
uri.query["leg"] == "1"
```

Missing keys are just empty strings, no need to check if its there or handle exceptions:

```nim
uri.query["missing"] == ""
````

You can also modify the query string with `[]=` method:

```nim
uri.query["missing"] = "no more!"
```

# API: uriiy

```nim
import uriiy
```

## **type** Uri


```nim
Uri = ref object
 scheme*, username*, password*: string
 hostname*, port*, path*, fragment*: string
 query*: seq[(string, string)]
```

## **func** `[]`

Get a key out of uri.query. Use a for loop to get multiple keys.

```nim
func `[]`(query: seq[(string, string)]; key: string): string
```

## **func** `[]=`

Sets a key in the uri.query. If key is not there appends a new key-value pair at the end.

```nim
func `[]=`(query: var seq[(string, string)]; key, value: string)
```

## **func** encodeUrlComponent

Takes a string and encodes it in the URI format.

```nim
func encodeUrlComponent(s: string): string
```

## **func** decodeUrlComponent

Takes a string and decodes it from the URI format.

```nim
func decodeUrlComponent(s: string): string {.raises: [ValueError].}
```

## **func** parseUri

Parses a URI or a URL into the Uri object.

```nim
func parseUri(s: string): Uri {.raises: [ValueError].}
```

## **func** host

Returns Host and port part of the URI as a string.

```nim
func host(uri: Uri): string
```

## **func** search

Returns the search part of the URI as a string.

```nim
func search(uri: Uri): string
```

## **func** authority

Returns the authority part of URI as a string.

```nim
func authority(uri: Uri): string
```

## **func** `$`

Turns Uri into a string. Preserves query string param ordering.

```nim
func `$`(uri: Uri): string
```
