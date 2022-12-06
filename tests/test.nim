import urlly

block:
  let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
  let url = parseUrl(test)
  assert url.scheme == "foo"
  assert url.username == "admin"
  assert url.password == "hunter1"
  assert url.hostname == "example.com"
  assert url.port == "8042"
  assert url.host == "example.com:8042"
  assert url.authority == "admin:hunter1@example.com:8042"
  assert url.paths == @["over", "there"]
  assert url.search == "name=ferret"
  assert url.query["name"] == "ferret"
  assert "name" in url.query
  assert "nothing" notin url.query
  assert url.fragment == "nose"
  assert $url == test

block:
  let test = "/over/there?name=ferret"
  let url = parseUrl(test)
  assert url.scheme == ""
  assert url.username == ""
  assert url.password == ""
  assert url.hostname == ""
  assert url.port == ""
  assert url.authority == ""
  assert url.paths == @["over", "there"]
  assert url.search == "name=ferret"
  assert url.query["name"] == "ferret"
  assert url.fragment == ""
  assert $url == test

block:
  let test = "?name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  let url = parseUrl(test)
  assert url.scheme == ""
  assert url.username == ""
  assert url.password == ""
  assert url.hostname == ""
  assert url.port == ""
  assert url.paths == @[]
  assert url.authority == ""
  assert url.search == "name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  assert url.query["name"] == "ferret"
  assert url.query["age"] == "12"
  assert url.query["leg"] == "1"
  assert "name" in url.query
  assert "age" in url.query
  assert "leg" in url.query
  assert "eye" notin url.query
  assert $url.query == """@[("name", "ferret"), ("age", "12"), ("leg", "1"), ("leg", "2"), ("leg", "3"), ("leg", "4")]"""
  assert url.fragment == ""
  assert $url == test

  var i = 1
  for (k, v) in url.query:
    if k == "leg":
      assert v == $i
      inc i

  assert url.query["missing"] == ""

block:
  let test = "?name=&age&legs=4"
  let url = parseUrl(test)
  assert url.query == @[("name", ""), ("age", ""), ("legs", "4")]

block:
  var url = Url()
  url.hostname = "example.com"
  url.query["q"] = "foo"
  url.fragment = "heading1"
  assert $url == "example.com?q=foo#heading1"

block:
  var url = Url()
  url.hostname = "example.com"
  url.query["site"] = "https://nim-lang.org"
  url.query["https://nim-lang.org"] = "nice!!!"
  url.query["nothing"] = ""
  url.query["unicode"] = "шеллы"
  url.query["specials"] = "\n\t\b\r\"+&="
  assert $url == "example.com?site=https%3A%2F%2Fnim-lang.org&https%3A%2F%2Fnim-lang.org=nice%21%21%21&nothing=&unicode=%D1%88%D0%B5%D0%BB%D0%BB%D1%8B&specials=%0A%09%08%0D%22%2B%26%3D"
  assert $parseUrl($url) == $url

block:
  let test = "http://localhost:8080/p2/foo%2Band%2Bother%2Bstuff"
  let url = parseUrl(test)
  assert url.paths == @["p2", "foo+and+other+stuff"]
  assert $url == "http://localhost:8080/p2/foo%2Band%2Bother%2Bstuff"

block:
  let test = "http://localhost:8080/p2/foo%2Fand%2Fother%2Fstuff"
  let url = parseUrl(test)
  assert url.paths == @["p2", "foo/and/other/stuff"]
  assert $url == "http://localhost:8080/p2/foo%2Fand%2Fother%2Fstuff"

block:
  let test = "http://localhost:8080/p2/#foo%2Band%2Bother%2Bstuff"
  let url = parseUrl(test)
  assert url.paths == @["p2", ""]
  assert url.fragment == "foo+and+other+stuff"
  assert $url == "http://localhost:8080/p2/#foo%2Band%2Bother%2Bstuff"

block:
  let test = "name=&age&legs=4"
  let url = parseUrl(test)
  assert url.query == @[("name", ""), ("age", ""), ("legs", "4")]

block:
  let test = "name=&age&legs=4&&&"
  let url = parseUrl(test)
  assert url.query ==
    @[("name", ""), ("age", ""), ("legs", "4"), ("", ""), ("", ""), ("", "")]

block:
  let test = "https://localhost:8080"
  let url = parseUrl(test)
  assert url.paths == @[]

block:
  let test = "https://localhost:8080/"
  let url = parseUrl(test)
  assert url.paths == @[""]

block:
  let test = "https://localhost:8080/&url=1"
  let url = parseUrl(test)
  assert url.paths == @[""]
  assert url.query == @[("url", "1")]
