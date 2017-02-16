## Server Side Swift with Vapor: Persisting Models with StORM

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can persist your data models into a database using a popular server side swfit framework called StORM.

StORM is a modular ORM for Swift, layered on top of Perfect. Basically, its aim is to make it easy to persist and retrieve your objects from a database - in a manner that's independent of what database engine you actually use.

StORM comes with implementations for CouchDB, SQLite, Postgres, and MySQL. In this screencast, we're going to use PostgreSQL, because it's popular, easy to set up, and it's what I've covered in other Server Side Swift videos.

If you want to use a different database provider, don't worry - you can take what you learn here and apply it to any database provider - you only have to change about a few lines of code.

## Before Demo

Drop all tables from db

## Demo 1

The first thing you need to do is install PostgresQL on your local machine. I've found the best way to do this is with brew, which you can install by going to brew.sh and following the instructions.

```
Install brew: http://brew.sh/
```

Once you've installed brew, run brew update, then brew install libxml2 - OK this isn't related to Postgres, but is a dependency that Perfect requires - and brew install postgres. I've aleady done this so I see a warning at this point. After it completes, run brew services start postgresql to start the database server - again I've already done this so I see a warning. 

Next we need to create a test user and database for our app to use. To do this, I'll run the create user command passing in -D to specify this user cannot create databases, -P to specify that it will need a password, and perfect as the username. I'll also enter perfect as the password.

Then I'll create a database with createdb, passing in -O to specify the owner of the database will be the perfect user we just created and enter perfect_testing as the name of the database.

Finally, enter psql to open the command line interface for PostgreSQL, using -d to sepcify perfect_testing as the database, and -U to specify perfect as the user. If it runs, that verifies everything is working OK, so we can quit with \q.

By the way, this user and db combination is frequenlty used in various Perfect samples, so now that you've set this up it will be easier for you to try them out later.

```
brew update
brew install libxml2
brew install postgres
brew services start postgresql
createuser -D -P perfect (enter "perfect" for the password when prompted)
createdb -O perfect perfect_testing
psql -d perfect_testing -U perfect
\q
```

## Interlude

Now that we have our database set up, we'll create a new Perfect project that stores a simple object into the database.

StORM makes this very simple: we just need to make our model object conform to the PostgresStORM protocol. Basically this means we have to write a method to convert our object into a row of data, and then another method to convert a result set into an array of our model objects.

Once we've done that, StORM has built-in methods like save(), findAll() and so on that makes storing and retrieving our data easy. The easiest way to understand how this works is to see it in action, so let's dive in.

## Demo

I've already got the Swift 3 toolchain and Perfect Assistant installed, so I'll create a new project in Perfect Assistant, using the Perfect Template App template. I'll browse to a directory to store this project in, and create a new directory called til - because that is the name of the web app we're eventually making - uncheck integrate Linux builds to save compile time, and click Save.

Perfect Assistant will set up a "Hello, Perfect" project for me. Before I open the project, I need to do two configuration things.

First, I'll open up terminal and create a new file we'll be creating our model object in:

```
touch Sources/Acronym.swift
```

Then back in Perfect Assistant, I'll drag Postgres-StORM up into the dependencies list, and click Save Changes. This will auto-regneerate the Xcode proejct, so at this point I can just click Open\Xcode project.

Let's start by making our acronym model object. We'll import StORM and PostgresStORM, and mark our model object as conforming to the PostgresStORM protocol. 

Our acronym will have three properties: one, its unique ID in the database, second, the short form of the acronym, like "BRB", and third the long form of the acronym like "Be Right Back."

```
import StORM
import PostgresStORM

class Acronym: PostgresStORM {

  var id: Int = 0
  var short: String = ""
  var long: String = ""

}
```

The first method we have to implement to conform to PostgresStORM is table. Here we simply return the name of the database table that corresponds to this model object. We'll call it acronyms.

```
	override open func table() -> String { return "acronyms" }
```

The second method you have to implement to conform to PostgresStORM is to. HEre you receive a row of data from the database, and you have to set each of your properties accordingly. I'll just look in the data dictionary for each field and set the property accordingly, casting if necessary.

```
	override func to(_ this: StORMRow) {
		id = this.data["id"] as? Int ?? 0
		short	= this.data["short"] as? String	?? ""
		long = this.data["long"] as? String	?? ""
	}
```

The next method I need to add isn't strictly required, but it's quite handy so I'm going to add it. Basically, often you run methods on StORM like findAll() that run a query on the database, adn populate self.results with an array of result rows. Often you want to easily convert this into an array of model objects. So I'll add a method to do this. It just loops through the results, creates an acronym for each, and returns the result. We'll use this method later in the screencast.

```
	func rows() -> [Acronym] {
		var rows = [Acronym]()
		for i in 0..<self.results.rows.count {
			let row = Acronym()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
```

Next, I'm going to make a method to return this model as a [String:Any] dictionary. This isn't required but makes it easy to return your data in JSON format.

```
  func asDictionary() -> [String: Any] {
    return [
      "id": self.id,
      "short": self.short,
      "long": self.long
    ]
  }
```  

Back in main.swift, I'll delete the  template code and start with some basic setup to create a server listening on port 8080.

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()

server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
```

Next, I'll import StORM and PostgresStORM, and configure the database with the test user and database we set up earlier.

```
import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username	= "perfect"
PostgresConnector.password	= "perfect"
PostgresConnector.database	= "perfect_testing"
PostgresConnector.port		= 5432
```

Next, I need to create the database table for Acronyms. Luckily, with StORM this is easy; I simply create an instance of the Acronym class and call setup. Behind the scences, StORM will create the database structure when this line is run.

```
let setupObj = Acronym()
try? setupObj.setup()
```

Let's test this out to prove that it works so far. I'll run the project, and then log into psql with our test user. Cool - I can see our database is set up.

```
psql -d perfect_testing -U perfect
\d
\d acronyms
\q
```

Back in **main.swift**, I'll add a new route for when you issue a GET to /test.

```
routes.add(method: .get, uri: "/test", handler: test)
```

Then I'll implement the handler. It will start by creating a new acronym and saving it to the database. Again StORM makes this simple - I simply create an acronym and set the properties the way I like, then call acronym.save. Upon success, this calls a closure with the ID of the new object in the database. I'll just set the ID back on the acronym object.

The second thing I want to do in this handler is return a list of all the acronyms in the database in JSON format. To do this, I can use StORM's findAll() method. I simply create a temporary Acronym object that is used just for retrieval, and call findAll() to retreive all acronms from the database. I then create an empty array of [String:Any] dictionaries - to collect the acronyms in a format that can easily be converted into JSON. 

Then, I use the rows() method I wrote earlier to convert the rows into an array of acronyms, and loop through each, calling row.AsDictionary() method we also wrote earlier.

Finally, I set the body of the response to a JSON version of the acronyms array, and set the header to application/JSON, and set it as completed as usual. If there's any error, I'll send a diagnostic message.

```
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
``` 

Now I'll build and run, and navigate to[http://localhost:8080/test](http://localhost:8080/test). I see that it has created an entry into the database, and if I refresh, it creates another.

Let's try creating an entry in the database manually, just to prove it works another way. I'll log in with psql, and create an entry for BRB. Now if I refresh the page, I see it!

```
psql -d perfect_testing -U perfect
select * from acronyms;
insert into acronyms(short, long) values ('BRB', 'Be Right Back');
```

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to persist your model objects in a database with StORM and Perfect.

There's a lot more you can do beyond just saving an model object to the database - you can also perform queries, delete data, and more - and that's the subject of my next screencast.

Speaking of models, you know I've never understood fashion models in real life - those people are just so clothes minded. Anyway - I'm out! :]