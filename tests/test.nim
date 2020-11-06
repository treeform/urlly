import urlly

block:
  let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
  let url = parseUrl(test)
  assert url.scheme == "foo"
  assert url.username == "admin"
  assert url.password == "hunter1"
  assert url.hostname == "example.com"
  assert url.port == "8042"
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

  for (k, v) in url.query:
    if k == "leg":
      echo v

  assert url.query["missing"] == ""

block:
  let test = "?name=&age&legs=4"
  let url = parseUrl(test)
  echo url.query

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
  echo $url
  assert $parseUrl($url) == $url
