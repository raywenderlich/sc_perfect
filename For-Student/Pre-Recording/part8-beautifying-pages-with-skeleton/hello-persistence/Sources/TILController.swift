import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

final class TILController {

  let documentRoot = "./webroot"

  var routes: [Route] {
    return [
      Route(method: .get, uri: "/til", handler: indexView),
    ]
  }

  func indexView(request: HTTPRequest, response: HTTPResponse) {
    do {
      var values = MustacheEvaluationContext.MapType()
      values["acronyms"] = try AcronymAPI.allAsDictionary()
      mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/index.mustache")
    } catch {
      response.setBody(string: "Error handling request: \(error)")
        .completed(status: .internalServerError)
    }
  }

}
