## Server Side Swift with Perfect: Templating with Mustache

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can use templating in your server side Swift apps - with Perfect and Mustache.

First of all - what is templating? Well, when you're writing a web app, you often want to return HTML, except certain parts of the HTML you want to fill with dynamic content. As a simple example, imagine you want to make the web page respond with "Hi", and the user's name.

Templating is the idea that you make a template of what you want to return - such as HTML - and wherever you want to put in dynamic content, you put a placeholder tag. For example, you might put #(name) for where you want the user's name to be. You then instruct the web framework to return the template, populated with a set of data you provide.

In this screencast, we're going to explore templating with a popular server side Swift framework called Perfect. Perfect comes with built-in support for Mustache, an extremely popular templating system that has been implemented in just about every language out there. 

Let's dive right in and create a simple Hello World with templating.

## Demo

I've already got the Swift 3 toolchain and Perfect Assistant installed, so I'll create a new project in Perfect Assistant, using the Perfect Template App template. I'll browse to a directory to store this project in, and create a new directory called hello-templating, uncheck integrate Linux builds to save compile time, and click Save.

Perfect Assistant will set up a "Hello, Perfect" project for me. Before I open the project, I need to do two configuration things.

First, I need to create a directory for the templates to be stored in, so I'll click Open\Project Directory and create a new directory called webroot. I'll then click Xcode Project\Regenerate so that it detects the new directory I created, and Open\Xcode Project. 

Second, I need to import the Mustache library itself. To do this, I'll just drag the entry for Mustache from the Utility section up to the dependencies, and click Save Changes. This will auto-regneerate the Xcode proejct, so at this point I can just click Open\Xcode project.

First, before I forget I'll select the second target, go to Edit Scheme, and set the working directory to the hello-templating directory.

Now let's create our first Mustache template. Inside **webroot**, I'll create a file called **hello.mustache**. 

Let's start simple by returning some basic HTML without any parameters to replace - we'll do that next. Note that you can return anything; it doesn't neceessarily need to be HTML. Also, to get syntax highlighting, just select editor\syntax coloring\HTML. 

```
<!DOCTYPE html>
<html lang="en">

  <head>
    <title>Hello, World!</title>
  </head>
  <body>
    <h1>Hello, World!</h1>
  </body>

</html>
```

OK, now let's set up a route in Perfect that will return this template. To do this, I'll delete all of this placeholder code and start up a simple server listening on port 8080 with the document route set. I'll add a function to render the template, which we'll fill in in a moment, and a route that will call it. Finally I'll start up the server and print any errors.

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

func helloMustache(request: HTTPRequest, response: HTTPResponse) {
  // TODO
}

routes.add(method: .get, uri: "/helloMustache", handler: helloMustache)

server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
```

In Perfect, to use Mustache you need to create a type that implements the MustachePageHandler protocol. The job of this type is to generate the data that will be use to fill in the mustache template. We're just going to create a simple implementation here that lets the caller pass in data directly. 

So I'll just add a property to store the data we'll pass to the template to render - for now it will be empty but later in the screencast we'll be adding values here. Note that MustacheEvaluationContext.MapType is just a [String:Any] dictionary.

The method I need to overwrite is called extendValuesForResponse. It will be easy in our case - I'll just pass in the values property to the context via the extendValues method. Then I'll try to complete the request, and if there's an error I'll log it out.

```
struct MustacheHelper: MustachePageHandler {
  var values: MustacheEvaluationContext.MapType

  func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
    contxt.extendValues(with: values)
    do {
      try contxt.requestCompleted(withCollector: collector)
    } catch {
      let response = contxt.webResponse
      response.appendBody(string: "\(error)")
        .completed(status: .internalServerError)
    }
  }
}
```

Now implementing helloMustache() will be easy. I'll just create an empty MapType, and I'll call a built-in perfect method called mustacheREquest, passing in the request, response, and the MustacheHelper we made earlier, passing in our empty dictionary. Finally for the template path, I'll pass in the path to the hello mustache template we made earlier.

Build and run, and check it out - we've got HTML!

## Interlude

Even though this is very basic, we've already got some benefit, because now our view is now in a separate file, which makes things a lot cleaner and more maintaniable than returning HTML from within our controller code. But the real power of templating comes with filling in dynamic data - so let's give that a try.

## Demo

Instead of saying Hello, World, I want this page to say Hello, and then the user's name. To this, I simply add a placeholder where I want the user's name: two opening curly braces, name, and to closing curly braces. Note that this looks kinda like a mustache - that's how it got its name.


```
<h1>Hello, {{name}}!</h1>
```

Back in main.swift, all I have to do is an an entry for name into the values dictionary - I'll set it to my name here.

```
values["name"] = "Ray"
```

I'll build and run - and awesome, I have dynamic data.

In the first Perfect screencast, I showed you how you can create routes that take parameters. Let's combine that idea with templating, so you can get the user's name from the route you visit. 

I'll create a new route here that takes a parameter called name, and calls helloMustache2.

```
routes.add(method: .get, uri: "/helloMustache2/{name}", handler: helloMustache2)
```

Inside hello mustache 2, I'll look up the name from the urlVariables dictionary, and if it isn't there I'll return an error. Otherwise, I'll just pass that name into the values dictionary and render the template as before.

```
func helloMustache2(request: HTTPRequest, response: HTTPResponse) {
  guard let name = request.urlVariables["name"] else {
    response.completed(status: .badRequest)
    return
  }
  var values = MustacheEvaluationContext.MapType()
  values["name"] = name
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello.mustache")
}
```

Build and run, and let's try this with a dynamic name. It works!

## Interlude

Replacing placeholders in your template is great, but it's very common to have a collection of items that you want to display on a page. On a blog you might have a collection of posts, on Twitter you might have a collection of tweets. Mustache also supports looping through a collection of data, through a feature called sections. Let's give this a try.

## Demo 

I'll create a new template here called hello2.mustache, and copy in the same HTML from earlier. Except this time, let's assume we're passed a colleciton of users, and for each one, we want to print out their name. 

To do this, I'll put users inside curly braces, but prefixed by a hash tag to indicate that this is a section. To close the section, I'll put users inside curly braces again, but prefixed by a slash to nidicate the section is complete. Inside the section, I can refer to any property that all the users contain. Our users will contain a name property to start, so I'll print that out.

```
<!DOCTYPE html>
<html lang="en">

  <head>
    <title>Hello, World!</title>
  </head>
  <body>

    {{#users}}
      <h1>Welcome, {{name}}!</h1>
    {{/users}}

  </body>

</html>
```

Back in **main.swift**, I'll add a new route for helloMustache3:

```
routes.add(method: .get, uri: "/helloMustache3", handler: helloMustache3)
```

This itme, instead of passing in a single value to values, we need to pass in a dictionary. For each user, I'll and an entry for their name.

```
func helloMustache3(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  values["users"] = [["name": "Ray"],
    ["name": "Vicki"],
    ["name": "Brian"]]
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello2.mustache")
}
```

I'll build and run - and nice, now I see a collection of users.

Usually when you have a collection of data like this, each element has more than one property. For example, a user might have a name, and an email address. To show you what I mean, I'll create a new route here that has users with both names and email addresses.

```
routes.add(method: .get, uri: "/helloMustache4", handler: helloMustache4)
```

```
func helloMustache4(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  values["users"] = [["name": "Ray", "email": "ray@razeware.com"],
    ["name": "Vicki", "email": "vicki@razeware.com"],
    ["name": "Brian", "email": "brian@razeware.com"]]
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello3.mustache")
}
```

I'll create a new template to display this, based on the previous template. It's the same as before, except to access the property within each user you just use the variable for each item - user in this case - and then put dot and the property you want to access - so user.name, and user.email. 

```
<!DOCTYPE html>
<html lang="en">

  <head>
    <title>Hello, World!</title>
  </head>
  <body>

    {{#users}}
      <h1>Hello, {{name}}! <a href="mailto:{{email}}">[Email]</a></h1>
    {{/users}}

  </body>

</html>
```

Build and run, and nice - we've got a dynamic collection of data.

There's one last thing I want to show you before I go on. Sometimes, you want something different to appear if you don't have any data in your section - for example, if there are 0 users. This is really easy - you put the name of the section in curly braces as before, except you use a caret to indicate that this should be displayed if there are no users.

```
    {{^users}}
      <h1>No users :[</h1>
    {{/users}}
```

We can test this out by creating a new route:

```
routes.add(method: .get, uri: "/helloMustache5", handler: helloMustache5)
```

And just not passing in any users this time.

```
func helloMustache5(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello3.mustache")
}
```

If I build and run - nice, I see it display that there are no users.

## Interlude

Often when you're creating templates like this you often have repeated elements. For example, all of the tempaltes we created so far have the same basic HTML structure. It would be terrible if we had 100 of these templates and then our designer came with a redesign - we'd have a lot of work on our hands.

As with programming, a general rule of thumb is don't repeat yourself - and luckily this easy with another feature of Mustache called partials.

## Demo

Take a look at our three mustache templates here. They all begin the exact same way, and end the exact same way; the only difference is the body of the page.

It would be great to put each of these sections into reusable files - and with mustache it's easy. I'll just copy the header material, and move it to a new file named header.mustache. Similarly, I'll copy the footer material, and move it to a new file named footer.mustache.

Then, in each of these files, I'll simply put the name of the file I want to import inside curly braces - but prefixed by a greater than sign to signify that it is a partial.

Now I'll build and run - and nice! Everything works as before, but our templates are much cleaner. 

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to create and render a template, add data to replace, loop through data, and reuse templates.

Now that you understand templating, I'm sure you're eager to integrate what you've learned here with actual dynamic content from a database. That is the subject of my next screencast!

Thanks for watching - I wish I could stay, but I really mustache. I'm out!