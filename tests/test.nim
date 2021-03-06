import urlly, strutils

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
  assert url.path == "/over/there"
  assert url.search == "name=ferret"
  assert url.query["name"] == "ferret"
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
  assert url.path == "/over/there"
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
  assert url.path == ""
  assert url.authority == ""
  assert url.search == "name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  assert url.query["name"] == "ferret"
  assert url.query["age"] == "12"
  assert url.query["leg"] == "1"
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
  let test = "http://localhost:8080/p2/foo%20and%20other%20stuff"
  let url = parseUrl(test)
  assert url.path == "/p2/foo and other stuff"

block:
  let test = "http://localhost:8080/p2/#foo%20and%20other%20stuff"
  let url = parseUrl(test)
  assert url.path == "/p2/"
  assert url.fragment == "foo and other stuff"