import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username	= "perfect"
PostgresConnector.password	= "perfect"
PostgresConnector.database	= "perfect_testing"
PostgresConnector.port		= 5432

let setupObj = Acronym()
try? setupObj.setup()

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()

func test(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Save acronym
    let acronym = Acronym()
    acronym.short = "AFK"
    acronym.long = "Away From Keyboard"
		try acronym.save { id in
      acronym.id = id as! Int
    }

    // Get all acronyms as dictionary
    let getObj = Acronym()
    try getObj.findAll()
    var acronyms: [[String: Any]] = []
    for row in getObj.rows() {
      acronyms.append(row.asDictionary())
    }

    try response.setBody(json: acronyms)
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func new(request: HTTPRequest, response: HTTPResponse) {
  do {

    guard let json = request.postBodyString,
          let dict = try json.jsonDecode() as? [String: String],
          let short = dict["short"],
          let long = dict["long"] else {
      response.completed(status: .badRequest)
      return
    }

    // Save acronym
    let acronym = Acronym()
    acronym.short = short
    acronym.long = long
		try acronym.save { id in
      acronym.id = id as! Int
    }

    try response.setBody(json: acronym.asDictionary())
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func all(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Get all acronyms as dictionary
    let getObj = Acronym()
    try getObj.findAll()
    var acronyms: [[String: Any]] = []
    for row in getObj.rows() {
      acronyms.append(row.asDictionary())
    }

    try response.setBody(json: acronyms)
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func first(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Get first acronym (limit to 1 result)
    let getObj = Acronym()
    let cursor = StORMCursor(limit: 1, offset: 0)
    try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)

    if let acronym = getObj.rows().first {
      try response.setBody(json: acronym.asDictionary())
        .setHeader(.contentType, value: "application/json")
        .completed()
    } else {
      try response.setBody(json: [])
        .setHeader(.contentType, value: "application/json")
        .completed()
    }
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func afks(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Get acronyms where short == "AFK"
    let getObj = Acronym()
    var findObj = [String: Any]()
    findObj["short"] = "AFK"
    try getObj.find(findObj)
    var acronyms: [[String: Any]] = []
    for row in getObj.rows() {
      acronyms.append(row.asDictionary())
    }

    try response.setBody(json: acronyms)
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func nonAfks(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Get acronyms where short != "AFK"
    let getObj = Acronym()
    try getObj.select(whereclause: "short != $1", params: ["AFK"], orderby: ["id"])
    var acronyms: [[String: Any]] = []
    for row in getObj.rows() {
      acronyms.append(row.asDictionary())
    }

    try response.setBody(json: acronyms)
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func update(request: HTTPRequest, response: HTTPResponse) {
  do {

    guard let json = request.postBodyString,
          let dict = try json.jsonDecode() as? [String: String],
          let short = dict["short"],
          let long = dict["long"] else {
      response.completed(status: .badRequest)
      return
    }

    // Get first acronym (limit to 1 result)
    let getObj = Acronym()
    let cursor = StORMCursor(limit: 1, offset: 0)
    try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
    guard let acronym = getObj.rows().first else {
      response.completed(status: .badRequest)
      return
    }

    // Update acronym
    acronym.short = short
    acronym.long = long
    try acronym.save()

    try response.setBody(json: acronym.asDictionary())
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}

func deleteFirst(request: HTTPRequest, response: HTTPResponse) {
  do {

    // Get first acronym (limit to 1 result)
    let getObj = Acronym()
    let cursor = StORMCursor(limit: 1, offset: 0)
    try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)

    guard let acronym = getObj.rows().first else {
      response.completed(status: .badRequest)
      return
    }

    // Delete
    try acronym.delete()

    // Get all acronyms as dictionary
    try getObj.findAll()
    var acronyms: [[String: Any]] = []
    for row in getObj.rows() {
      acronyms.append(row.asDictionary())
    }

    try response.setBody(json: acronyms)
      .setHeader(.contentType, value: "application/json")
      .completed()

  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}


routes.add(method: .get, uri: "/test", handler: test)
routes.add(method: .post, uri: "/new", handler: new)
routes.add(method: .get, uri: "/all", handler: all)
routes.add(method: .get, uri: "/first", handler: first)
routes.add(method: .get, uri: "/afks", handler: afks)
routes.add(method: .get, uri: "/non-afks", handler: nonAfks)
routes.add(method: .post, uri: "/update", handler: update)
routes.add(method: .get, uri: "/delete-first", handler: deleteFirst)

server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
