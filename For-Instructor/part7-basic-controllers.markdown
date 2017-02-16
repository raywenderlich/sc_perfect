## Server Side Swift with Perfect: Basic Controllers (1133 words, ~5.1 min)

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can better organize your Perfect apps by using basic controller objects.

When you're first starting to learn Perfect, you'll probably start creating different routes directly in main.swift. But if you keep doing this, eventually it will become a cluttered mess.

A better practice is to separate the logic for your web app into different classes, each of which have their own clear responsibilities. I'm going to show you one way of doing this that makes senese to me, but keep in mind you can architect things differnetly if you prefer. Let's dive right in.

## Demo

I have a Perfect project here that has a simple model class, and is configured to store this model in a database. Right now, you can see that my main.swift is cluttered with all kinds of test routes - and most of these methods are quite long, doing many different responsibilites.

For example, this test route does two different responsibilities: 1) it deals with the request/response, 2) it parses to/from JSON and interacts with the Acronym class.

Let's see how we can clean this up by creating a separate objects for each responsibility. First, let's use Perfect Assistant to open a terminal to our project folder, and create two new files: 

  * AcronymAPI.swift, which will be responsible for converting to/from JSON, and interacting w/ the Acronym class.
  * BasicController.swift, which will store the routes, work with the request/response objects, and handle exceptions.

```
touch Sources/AcronymAPI.swift
touch Sources/BasicController.swift
```

We'll then use Perfect Assistant to regenerate our Xcode project so it detects the new files.

Let's start by cleaning up one route at a time, so you can see how things work. We'll start with this test method here - our goal is to move it completely out of this file, and better organize each piece of logic in the appropriate spot.

Let's start with BasicController.swift. We'll import a few frameworks, add a comment to remind ourselves of its responsibilities, and then create a plain old Swift class.

```
import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Responsibility: call appropriate func, deal with request/response, exception handling

final class BasicController {

}
```

Now let's open up main.swift. My goal here is to eventually move all of these routes into my new controller class. Let's start with the test method we're working on now. I'll copy the route, and then switch back to the controller.

I'll simply make a new property that returns an array of routes, and I'll paste in the code here and tweak it slightly.

```
  var routes: [Route] {
    return [
      Route(method: .get, uri: "/test", handler: test),
    ]
  }
```  

Next, let's copy the method body into this class. There's one big difference though - this top part deals with the Acronym object and JSON, which is the responsibility of AcronymAPI. So we'll delete all this and call a method on AcronymAPI we'll write in a second to do all of this.

We're going to make this method pre-convert the JSON into a string, so I'll update setBody from json to a string.

Now we'll add the code we deleted earlier into the AcronymAPI class. As before we'll start with a plain old Swift class.

```
import Foundation

// Responsibility: Convert to/from JSON, interact w/ Acronym class
class AcronymAPI {

}
```

Then we'll create our test method, and simply paste in the code we deleted earlier. We'll tweak the final result to convert the dictionary into a JSON-encoded string.

```
  static func test() throws -> String {
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

    return try acronyms.jsonEncodedString()
  }
```

We could go with this, but we can do better. The bit at the bottom that gets the acronyms as a dictionary contians a lot of code we'll want to reuse later, so let's refactor this a bit further. 

Let's refactor these first to lines here, which retrieve all acronyms. Personally I think a good spot for this would be on the Acornym class itself, so I'll add that there.

```
static func all() throws -> [Acronym] {
  let getObj = Acronym()
  try getObj.findAll()
  return getObj.rows()
}
```

Next we need to refactor these lines here, which convert the acronyms into an array of [String:Any] dictionaries. We'll create an acronymsToDcitionary method that does this.


```
  static func acronymsToDictionary(_ acronyms: [Acronym]) -> [[String: Any]] {
    var acronymsJson: [[String: Any]] = []
    for row in acronyms {
      acronymsJson.append(row.asDictionary())
    }
    return acronymsJson
  }
```

Then, we'll create a helper that calls the all() method we wrote, followed by the acronymsToDictionary() method we wrote.

```
  static func allAsDictionary() throws -> [[String: Any]] {
    let acronyms = try Acronym.all()
    return acronymsToDictionary(acronyms)
  }
```

And finally, we'll add one more helper that calls the previous method, and converts it to a JSON encoded string.

```
  static func all() throws -> String {
    return try allAsDictionary().jsonEncodedString()
  }
```  

At this point, we can simplify our test() method greatly, and delete all this code and replace it with just a return try all().

```
return try all()
```

Let's try this out. Back in main.swift, I'll delete the test handler, and the test route. I'll also create a new BasicController, and register the routes I still have in main.swift along with the routes from BasicController.

```
let basic = BasicController()
server.addRoutes(Routes(basic.routes))
```

Now I'll build and run, and go to /test - and nice - it works as before.

At this point, I can repeat this process to clean up the rest of the routes. This is repetitive and a bit boring, so I'll do this offline.

[Offline: copy code from finished project]

As you can see, at this poing my main.swift file is nice and clean, BasicController is easy to read, and AcronymAPI is nicely refactored. 

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to refactor your code out of your main.swift into objects with separate responsibilities. If you want to review any of the code, you can download the completed project below.

Keep in mind this is one of many solutions - feel free to design things differently if it makes sense to you. The important thing is to avoid duplication and clutter as much as you can, and have clear areas of responsibility.

I hope that this screencast has helped you better... control your web app architecture. I'm out!