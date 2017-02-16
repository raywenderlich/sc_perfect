## Server Side Swift with Perfect: CRUD Database Operations with StORM 

## Introduction

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can create, read, update, and delete data in a database using Perfect, a popular server side Swift framework. 

It's actually remarkably easy thanks to StORM - Perfect's built-in object relational mapping library. As long as you make your objects conform to StORM's protocol, you're pretty much set, and can use built-in calls to retrieve, update, and delete objects from the database. Let's give it a try.

## Demo

I have a simple Perfect project here. I've configured it to use a PostgreSQL database, and I've created an object that conforms to the PostgresStORM protocol. You can see it's pretty simple - it has a method to convert from the a database row, a moethod to convert a set of results into an array of model objects, and a helper method to return the object as a dictionary to ease in JSON conversion.

Let's start by seeing how to create a new object in the database. I'll create a new route to handle a POST request, called new. 

```
routes.add(method: .post, uri: "/new", handler: new)
```

I'll assume that the post body contains some JSON data. I'll decode the data, and look for two parameters: the short and long form of an acronym to create.

Thanks to StORM, saving the acronym is very simple. I just create a new Acronym model object, and then call save. Upon success, this calls a closure with the ID of the new object in the database. I'll just set the ID back on the acronym object.

Aftewards, I return the new acronym as JSON, and if there's an error print that out as well.

```
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
```

Now I'll build and run, load up Rested, set up the post to create a new object - looks good! I can verify that it has saved this object to the database with psql:

```
POST to http://localhost:8080/new
```

```
psql -d perfect_testing -U perfect
select * from acronyms;
\q
```

OK, so that's create. What about read? Let's start by making a route that will return all acronyms in the datbase. I'll create a new route to handle a GET request, called all. 

```
routes.add(method: .get, uri: "/all", handler: all)
```

To get all Acronyms in the database, all I need to do is create a temporary Acronym object, and then call findAll(). Finally I need to convert the result to an array of [String:Any] dictionaries so I can return it as JSON.

```
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
```

If I try this out with Rested - it works!

## Interlude

At this point, you know how to create objects and read all objects. But often, you want to read a subset of objects, rather than all objects. StORM makes this extremely easy through powerful query capability - let's take a look.

## Demo

Let's create a new route called first to return the first acronym in the database. 

```
routes.add(method: .get, uri: "/first", handler: first)
```

One way to run a query on your database table with StORM, is to use the select() method. This gives you full control - you can specify the where clause to limit the results, you can specify parameters to substitute in the where clauss, you can specify the ordering and you can also specify a datase cursor to use. The cursor allows you to limit the number of rows that are returned, and specify an offset for where to begin in the query results, which is useful for pagination.

Here we'll set up a cursor to only return one row no matter what. This is good for performance, just in case this table contains hundreds of rows.

Then we'll check to see if there's a result, and if so return it - otherwise return an empty array.

```
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
```

Let's create another route to return any acronyms with the short field set to AFK. 

```
routes.add(method: .get, uri: "/afks", handler: afks)
```

This time we'll use an alternate method to query your database table using StORM. We create a String:Any dictionary, and specify any field we want to match on our object. In this case, we want any acronyms where the short field is AFK. We then call find() pasisng in our dictionary, and return the results as usual.

This method is a little bit easier for simple queries like this.

```
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
```

Let's try the other way round, and create a route to return anything but AFKs. 

This time we have to go back to using the select clause, since we want a not equal comparison. This time we use the wher clause, setting short != $1, where $1 is a placeholder for the first parameter - which protects you against SQL injection attacks. in the params, we specify AFK for the parameter, and order by ID. Then we return the results as usual.

```
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
```

Now let's try these all out. I'll call first to get the first entry. Then I'll find the AFK entries, and finally the non-AFK entries. That's a lot of reading! 

## Interlude

At this point we've covered Create and Read. Now let's cover the last two: Update and Delete.

## Demo

Let's create a new route that will let us update the first acronym in the database. We'll look for a POST to /update.

```
routes.add(method: .post, uri: "/update", handler: update)
```

We'll copy our new method to use as a starting point, since we'll be looking for the same JSON parameters. Then we'll get the first acronym, same as we did before. If there is no acronym, we'll thrown an error. 

Here's where the update magic happens. Since the ID has been set when we pulled the first acronym, all we have to do is update the short and long on the acronym, and call save - that's it!

```
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
```

If I build and run, I can check what the first entry is, and then call update to give it a new definition.

Now it's time for the final operation - delete! Let's create a route that deletes the first acronym in the database.

```
routes.add(method: .get, uri: "/delete-first", handler: deleteFirst)
```

To do this I'll look up the first row as usual, but then I'll call delete() on the acronym. Afterwards, I'll return all acronyms.

```
// Delete
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
```

Now let's try all these out. I can use first to see the first entry, afks to see all afk entries, non-afks to see the rest, and delete-first to delete the first entry. 

## Conclusion

CRUD - is this screencast over already?! 

At this point, you should understand how to to create, read, update, and delete data in a database using Perfect.

At this point, you may be wondering if there's a better way to organize our code here - there's a lot of repeated code in main.swift, and it's getting quite cluttered. Good news - that's the subject of my next screencast!

Thanks for watching, and I'm out. :]
