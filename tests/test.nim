import uriiy

block:
  let test = "foo://admin:hunter1@example.com:8042/over/there?name=ferret#nose"
  let uri = parseUri(test)
  assert uri.scheme == "foo"
  assert uri.username == "admin"
  assert uri.password == "hunter1"
  assert uri.hostname == "example.com"
  assert uri.port == "8042"
  assert uri.authority == "admin:hunter1@example.com:8042"
  assert uri.path == "/over/there"
  assert uri.search == "name=ferret"
  assert uri.query["name"] == "ferret"
  assert uri.fragment == "nose"
  assert $uri == test

block:
  let test = "/over/there?name=ferret"
  let uri = parseUri(test)
  assert uri.scheme == ""
  assert uri.username == ""
  assert uri.password == ""
  assert uri.hostname == ""
  assert uri.port == ""
  assert uri.authority == ""
  assert uri.path == "/over/there"
  assert uri.search == "name=ferret"
  assert uri.query["name"] == "ferret"
  assert uri.fragment == ""
  assert $uri == test

block:
  let test = "?name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  let uri = parseUri(test)
  assert uri.scheme == ""
  assert uri.username == ""
  assert uri.password == ""
  assert uri.hostname == ""
  assert uri.port == ""
  assert uri.path == ""
  assert uri.authority == ""
  assert uri.search == "name=ferret&age=12&leg=1&leg=2&leg=3&leg=4"
  assert uri.query["name"] == "ferret"
  assert uri.query["age"] == "12"
  assert uri.query["leg"] == "1"
  assert $uri.query == """@[("name", "ferret"), ("age", "12"), ("leg", "1"), ("leg", "2"), ("leg", "3"), ("leg", "4")]"""
  assert uri.fragment == ""
  assert $uri == test

  for (k, v) in uri.query:
    if k == "leg":
      echo v

  assert uri.query["missing"] == ""

block:
  let test = "?name=&age&legs=4"
  let uri = parseUri(test)
  echo uri.query

block:
  var uri = Uri()
  uri.hostname = "example.com"
  uri.query["q"] = "foo"
  uri.fragment = "heading1"
  assert $uri == "example.com?q=foo#heading1"

block:
  var uri = Uri()
  uri.hostname = "example.com"
  uri.query["site"] = "https://nim-lang.org"
  uri.query["https://nim-lang.org"] = "nice!!!"
  uri.query["nothing"] = ""
  uri.query["unicode"] = "шеллы"
  uri.query["specials"] = "\n\t\b\r\"+&="
  echo $uri
  assert $parseUri($uri) == $uri
