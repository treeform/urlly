import urlly

block:
  let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
  let url = parseUrl(test)
  doAssert url.scheme == "foo"
  doAssert url.username == "admin"
  doAssert url.password == "hunter1"
  doAssert url.hostname == "example.com"
  doAssert url.port == "8042"
  doAssert url.host == "example.com:8042"
  doAssert url.authority == "admin:hunter1@example.com:8042"
  doAssert url.paths == @["over", "there"]
  doAssert url.search == "name=ferret"
  doAssert url.query["name"] == "ferret"
  doAssert "name" in url.query
  doAssert "nothing" notin url.query
  doAssert url.fragment == "nose"
  doAssert $url == test

block:
  let test = "/over/there?name=ferret"
  let url = parseUrl(test)
  doAssert url.scheme == ""
  doAssert url.username == ""
  doAssert url.password == ""
  doAssert url.hostname == ""
  doAssert url.port == ""
  doAssert url.authority == ""
  doAssert url.paths == @["over", "there"]
  doAssert url.search == "name=ferret"
  doAssert url.query["name"] == "ferret"
  doAssert url.fragment == ""
  doAssert $url == test

block:
  let test = "?name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  let url = parseUrl(test)
  doAssert url.scheme == ""
  doAssert url.username == ""
  doAssert url.password == ""
  doAssert url.hostname == ""
  doAssert url.port == ""
  doAssert url.paths == @[]
  doAssert url.authority == ""
  doAssert url.search == "name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  doAssert url.query["name"] == "ferret"
  doAssert url.query["age"] == "12"
  doAssert url.query["leg"] == "1"
  doAssert "name" in url.query
  doAssert "age" in url.query
  doAssert "leg" in url.query
  doAssert "eye" notin url.query
  doAssert url.search == "name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  doAssert url.fragment == ""
  doAssert $url == test

  var i = 1
  for (k, v) in url.query:
    if k == "leg":
      doAssert v == $i
      inc i

  doAssert url.query["missing"] == ""

block:
  let test = "?name=&age&legs=4"
  let url = parseUrl(test)
  doAssert url.query == @[("name", ""), ("age", ""), ("legs", "4")]

block:
  var url = Url()
  url.hostname = "example.com"
  url.query["q"] = "foo"
  url.fragment = "heading1"
  doAssert $url == "example.com?q=foo#heading1"

block:
  var url = Url()
  url.hostname = "example.com"
  url.query["site"] = "https://nim-lang.org"
  url.query["https://nim-lang.org"] = "nice!!!"
  url.query["nothing"] = ""
  url.query["unicode"] = "шеллы"
  url.query["specials"] = "\n\t\b\r\"+&="
  doAssert $url == "example.com?site=https%3A%2F%2Fnim-lang.org&https%3A%2F%2Fnim-lang.org=nice%21%21%21&nothing=&unicode=%D1%88%D0%B5%D0%BB%D0%BB%D1%8B&specials=%0A%09%08%0D%22%2B%26%3D"
  doAssert $parseUrl($url) == $url

block:
  let test = "http://localhost:8080/p2/foo+and+other+stuff"
  let url = parseUrl(test)
  doAssert url.paths == @["p2", "foo+and+other+stuff"]
  doAssert $url == "http://localhost:8080/p2/foo%2Band%2Bother%2Bstuff"

block:
  let test = "http://localhost:8080/p2/foo%2Band%2Bother%2Bstuff"
  let url = parseUrl(test)
  doAssert url.paths == @["p2", "foo+and+other+stuff"]
  doAssert $url == "http://localhost:8080/p2/foo%2Band%2Bother%2Bstuff"

block:
  let test = "http://localhost:8080/p2/foo%2Fand%2Fother%2Fstuff"
  let url = parseUrl(test)
  doAssert url.paths == @["p2", "foo/and/other/stuff"]
  doAssert $url == "http://localhost:8080/p2/foo%2Fand%2Fother%2Fstuff"

block:
  let test = "http://localhost:8080/p2/#foo%2Band%2Bother%2Bstuff"
  let url = parseUrl(test)
  doAssert url.paths == @["p2", ""]
  doAssert url.fragment == "foo+and+other+stuff"
  doAssert $url == "http://localhost:8080/p2/#foo%2Band%2Bother%2Bstuff"

block:
  let test = "name=&age&legs=4"
  let url = parseUrl(test)
  doAssert url.query == @[("name", ""), ("age", ""), ("legs", "4")]

block:
  let test = "name=&age&legs=4&&&"
  let url = parseUrl(test)
  doAssert url.query ==
    @[("name", ""), ("age", ""), ("legs", "4"), ("", ""), ("", ""), ("", "")]

block:
  let test = "https://localhost:8080"
  let url = parseUrl(test)
  doAssert url.paths == @[]

block:
  let test = "https://localhost:8080/"
  let url = parseUrl(test)
  doAssert url.paths == @[""]

block:
  let test = "https://localhost:8080/&url=1"
  let url = parseUrl(test)
  doAssert url.paths == @[""]
  doAssert url.query == @[("url", "1")]

block:
  let test = "https://localhost:8080/?url=1"
  let url = parseUrl(test)
  doAssert url.paths == @[""]
  doAssert url.query == @[("url", "1")]
