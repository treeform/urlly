# Urlly (Pronounced "you-really?")

URL and URI parsing for Nim for C/JS backends. Similar api to browsers's `window.location`.

Nim's standard library `uri` module does not parse the query string. And Nim's standard library `cgi` module does not work in `js` mode. This module works everywhere and parses everything! Including providing an easy way to work with the query key-value pairs.

```
  foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose
  \_/   \___/ \_____/ \_________/ \__/\_________/ \_________/ \__/
   |      |       |       |        |       |          |         |
scheme username password hostname port   path       query fragment
```

## Using the `parseUrl()`.

```nim
let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
let url = parseUrl(test)
url.scheme == "foo"
url.username == "admin"
url.password == "hunter1"
url.hostname == "example.com"
url.port == "8042"
url.authority == "admin:hunter1@example.com:8042"
url.path == "/over/there"
url.search == "name=ferret"
url.query["name"] == "ferret"
url.fragment == "nose"
$url == test
```

## Using the `$()`.

You can always turn a `Url` into a `string` with the `$` function.

```nim
var url = Url()
url.hostname = "example.com"
url.query["q"] = "foo"
url.fragment = "heading1"
assert $url == "example.com?q=foo#heading1"
```

## Using the `query` parameter.

The `Url.query` is just a sequence of key value pairs (`seq[(string, string)]`). This preserves their order and allows 100% exact reconstruction of the url string. This also allows you to walk through each pair looking for things you need:

```nim
let url = parseUrl("?name=ferret&age=12&leg=1&leg=2&leg=3&leg=4")

for (k, v) in url.query:
if k == "leg":
    echo v
```

But for most use cases a special `[]` is provided. This is the most common use of the query.

```nim
url.query["name"] == "ferret"
```

If the key repeats multiple times only the first one is returned using the `[]` method. Use the for loop method if you need to support multiple keys or preserves special ordering.

```nim
url.query["leg"] == "1"
```

Missing keys are just empty strings, no need to check if its there or handle exceptions:

```nim
url.query["missing"] == ""
````

You can also modify the query string with `[]=` method:

```nim
url.query["missing"] = "no more!"
```

# API: urlly

```nim
import urlly
```

## **type** Url


```nim
Url = ref object
 scheme*, username*, password*: string
 hostname*, port*, path*, fragment*: string
 query*: seq[(string, string)]
```

## **func** `[]`

Get a key out of url.query. Use a for loop to get multiple keys.

```nim
func `[]`(query: seq[(string, string)]; key: string): string
```

## **func** `[]=`

Sets a key in the url.query. If key is not there appends a new key-value pair at the end.

```nim
func `[]=`(query: var seq[(string, string)]; key, value: string)
```

## **func** encodeUrlComponent

Takes a string and encodes it in the URL format.

```nim
func encodeUrlComponent(s: string): string
```

## **func** decodeUrlComponent

Takes a string and decodes it from the URL format.

```nim
func decodeUrlComponent(s: string): string {.raises: [ValueError].}
```

## **func** parseUrl

Parses a URL or a URL into the Url object.

```nim
func parseUrl(s: string): Url {.raises: [ValueError].}
```

## **func** host

Returns hostname and port part of the URL as a string. Example: "example.com:8042"

```nim
func host(url: Url): string
```

## **func** search

Returns the search part of the URL as a string. Example: "name=ferret&amp;age=12&amp;legs=4"

```nim
func search(url: Url): string
```

## **func** authority

Returns the authority part of URL as a string. Example: "admin:hunter1@example.com:8042"

```nim
func authority(url: Url): string
```

## **func** `$`

Turns Url into a string. Preserves query string param ordering.

```nim
func `$`(url: Url): string
```
