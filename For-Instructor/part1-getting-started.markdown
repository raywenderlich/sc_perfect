## Server Side Swift with Perfect: Getting Started

Hey what's up everybody, this is Ray. In today's screencast, I'm going to introduce you to a really popular server side swift framework called Perfect.

Before we begin, I just want to mention that I've made a similar screencast series on a different Server Side Swift framework called Vapor. Server Side Swift is in still the early days and there's a lot of great server side swift frameworks out there to choose between. I'm just trying to show you what the options are, and how each of them work. I recommend you choose the framework you want to work with and watch that screencast series - or if you're not sure which is best for you - watch them both and make your own decision!

Allright, back to Pefect. Perfect is an open source server side Swift framework created by a startup called PerfectlySoft Inc. Basically Perfect lets you write web applications, and web services, using Swift. 

Perfect has all the features you'd expect in a server side web framework, including handling HTTP requests, serving JSON, routing, templating, persitence, authentication, and more. At the time of making this screencast, Perfect has the most stars of any Server Side Swift framework on GitHub. So I'm really excited to show it to you today!

The easiest way to understand Perfect is to start using it, so let's dive in.

## Demo 1

To use Perfect, you need to have Swift 3 installed. If you're on a Mac, all you need to do is download and run Xcode 8 and you're set. If you're on Linux, you need to install the Swift 3 toolchain first, and those are steps are outlined on Swift.org here:

```
https://swift.org/getting-started/#installing-swift
```

If you're on Linux, you also have to install a few libraries that Perfect depends upon, which are outlined on Perfect.org's getting started page here:

```
http://perfect.org/docs/gettingStarted.html
```

I'm on a Mac, and I already have Swift 3 installed, so let's start by creating a command-line Swift app, that we'll eventually import Perfect into. 

To do this, I'll make a directory called "til", because that's the name of the project we'll be building in this screencast series. Then, I'll use Swift package manager to initialize a new package of type executable. I'll then use Swift package manager to generate an Xcode project, because I prefer to use Xcode as my IDE. I'll then open up the generated project, switch to the second target, and build and run.

```
mkdir til
cd til
swift package init --type executable
swift package generate-xcodeproj
open ./til.xcodeproj/
```

If I look at the console, I see that it printed Hello World. This is because main.swift contains a print statement for Hello World.

## Interlude

Now that I have a working command line app, let's import Perfect using Swift Package Manager so we can make our first Perfect app.

## Demo

To do this, I'll open Package.swift and add the required package dependency for Perfect.

```
import PackageDescription

let package = Package(
    name: "til",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),        
    ]
)
```

Then I'll switch to Terminal, and use swift package update to update my package dependencies, which behind the scenes will download the Perfect packages. I'll also regenerate my xcode project.

```
swift package update
swift package generate-xcodeproj
```

To test that the package imported successfully, I'll open main.swift and import PerfectLib, PerfectHTTP, and PerfectHTTPServer. I'll do a quick build, and don't have any errors, so the import worked OK.

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
```

Next, let's set up Perfect to be a basic web server that just serves local files. Back in Terminal, I'll make a directory named webroot, create an empty file called hello.txt inside that directory, and regenerate the xcode project.

```
mkdir webroot
touch webroot/hello.txt
swift package generate-xcodeproj
```

I'll open hello.txt and put some placeholder text in here just so we have a test file to return.

```
Hello, web server!
```

Back in main.swift, I'll delete the print statement, and create a new Perfect HTTP server using the built-in HTTPServer class. I'll set the server's port to 8080, and set the root directory that the server serves files from to the webroot directory that we just created. 

Then, I'll try to start the server. This can throw exceptions - for example if the port is already taken - so if there's any problem I'll catch it and print out the error.

```
let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
```

Before I run this I have to set the working directory for this app to the correct path. To do this, I'll switch to the second target, and click Edit Scheme. In Options, I'll set the working directory to the root directory of this project: the "til" directory.

Now I'll build and run, and I see in the console that Perfect has started a HTTP server on port 8080. I can open a web browser and navigate to localhost:8080/hello.txt and see the file that we created earlier. Nice!

## Interlude

At this point, we have a basic Perfect HTTP server running. That's cool, but what you really want to do is when you go to a certain URL, you want to run your own Swift code so you can take a look at the HTTP request, run your own custom logic, and return a custom HTTP response.

Perfect makes this easy through the idea of routes. Basically you specify three things: 1) the HTTP method you want to handle, such as GET or POST, 2) the URI in your domain that you're interested in handling - such as /hello, and 3) a swift closure to execute once a request comes in that matches this route.

Let's try this out by creating a route that will run some custom Swift code when you navigate to the index of our web site.

## Demo

In main.swift I'll create a new object called Routes(), which is a built-in class from Perfect that manages the routes for your web app. We'll use this to add a route that handles a GET with the URI "/", which will match a get to the index of the web app. For the handler, we'll specify a closure that takes a HTTP request object and a HTTP response object as parameters. 

For now, we'll simply set the body of the response to a string of "Hello, Perfect!" and mark the response as completed. It's important to remember to call completed or the response won't be sent. Finally, I'll call addRoutes on the server passing in my collection of routes.

```
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
  request, response in
  response.setBody(string: "Hello, Perfect!")
    .completed()
})
server.addRoutes(routes)
```

If we build and run, test this out in my web browser - it works!

Often when you're writing a web API, you want to respond with JSON, and Perfect makes that extremely easy. We'll be returning JSON frequently in the rest of this screencast, so I'm going to create a helper method for this called returnJSONMessage, that takes a message to return, and an HTTP response object.

Inside, I'll set the body of the response again, but this time I'll use the json: method instead of the :string method like we did before. Basically this method allows you to pass in an object that conforms to JSONConverible. Perfect has already implemented JSONConvertible on a lot of built-in Swift types like Strings, Ints, Arrays, and Dictionaries, and you can also implement it on your own types. So we'll just pass in a dictionary with the key "message" and the value the string message that is passed in.

Perfect also allows you to specify HTTP headers using the setHeader method, so we'll use that here to set the content type to application/json. As always we have to remember to mark the response as completed. As before, if there are any errors, we'll return the error in the response instead.

```
func returnJSONMessage(message: String, response: HTTPResponse) {
  do {
    try response.setBody(json: ["message": message])
      .setHeader(.contentType, value: "application/json")
      .completed()
  } catch {
     response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}
```

Now I'll try this out by creating a new route that handles a GET to /hello, and it will simply call this helper method, passing in "Hello, JSON" as the message. 

```
routes.add(method: .get, uri: "/hello", handler: {
  request, response in
  returnJSONMessage(message: "Hello, JSON!", response: response)
})
```

If I build and run, and this out in my web browser - we've got JSON!

You can also nest paths by passing in multiple parameters like this. And here's what it looks like in the browser.

```
routes.add(method: .get, uri: "/hello/there", handler: {
  request, response in
  returnJSONMessage(message: "I am tired of saying hello!", response: response)
})
```

Also, you can configure paths that take parameters. For example, let's say we want to go to /beers/number and use whatever number of beers the user passes into that URL as a parameter. 

To do this, simply pass in your path as usual, but for any path you want to use as a parameter, put a variable name for that parameter surrounded by curly braces. Then, inside your handler you can pull that out in the urlVariables property on the request. This is a string, so in this case we'll cast it to an int, and if anything goes wrong we'll fail as a bad request. Then, we'll return a message using our parameter.

```
routes.add(method: .get, uri: "/beers/{num_beers}", handler: {
  request, response in
  guard let numBeersString = request.urlVariables["num_beers"],
    let numBeersInt = Int(numBeersString) else {
    response.completed(status: .badRequest)
    return
  }
  returnJSONMessage(message: "Take one down, pass it around, \(numBeersInt - 1) bottles of beer on the wall...", response: response)
})
```

If I build and run, I can pass in 99 beers, and the web app generates a song for me. Cool!

In addition to GET requests, Perfect can handle all the other HTTP methods, like put, patch, delete, and so on. For example, you can simply set the method to post, pass in the path we want to run this on, and our closure as usual.

To get a parameter passed in by the HTTP post, you can simply use the request.param method. I'll try accessing the name parameter here, and if this fails I'll return an error instead.

Now let's just return out a message including this name and build and run. I'll use the Rested app to test out the post - and it works! Note it only works if it's form-encoded, not JSON encoded; you'd have to add some extra code to support JSON encoding with Perfect.

```
routes.add(method: .post, uri: "post", handler: {
  request, response in
  guard let name = request.param(name: "name") else {
    response.completed(status: .badRequest)
    return
  }
  returnJSONMessage(message: "Hello, \(name)!", response: response)
})
```

## Closing 

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to create a basic Perfect app, handle GET and POST http requests, and configure routing.

There's a lot more to Perfect - including templating, persitence, deploying, and more which I'll be covering in other screencasts, so it would be "perfect" if you could keep an eye out for those. Allright, I'm out!