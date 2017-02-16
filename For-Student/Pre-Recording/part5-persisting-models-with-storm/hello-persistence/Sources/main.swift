import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
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

routes.add(method: .get, uri: "/test", handler: test)

server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
