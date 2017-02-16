## Server Side Swift with Perfect: Beautifying Pages with Skeleton

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can easily beautify your Perfect web apps using Skeleton.

Often, you want to prototype a web app, but you may not be an amazing designer able to just whip up some amazing looking CSS from scratch.

In that case, it's handy to use a CSS boilerplate library, like Bootstrap, Foundation, or Skeleton. These libraries are designed to give you some basic CSS that makes your web apps look decent out of the box, and even better work responsively - usually by helping you lay out your web pages on a grid system. The idea is after you prototype the app, you or your designer can extend and customize this base CSS.

In this screencast, we're going to look at one particular CSS boilerplate library called Skeleton. I like Skeleton because it's dead-simple, quick to learn, it has a nice grid system, and still looks pretty decent. Even if you don't want to use Skeleton, you may find this screencast useful, because I show you how you can include public files into your Vapor apps.

# Before Demo

[Copy starter project over]

# Demo

I have a simple Perfect app here that has a model object called Acronym, and is configured to use a database. It has an API for performing various operations upon this model object using JSON, and a controller that registers for various test routes and calls the API appropriately.

I'll use Perfect Assistant to open a terminal to this directory, and I'll create some empty files that we'll be wriging in this screencast. We'll need one called TILController.swift and one called MustacheHelper.swift.


```
touch Sources/TILController.swift
touch Sources/MustacheHelper.swift
```

This project will also need to use Mustache, so I'll drag that up into the dependencies, and click Save Changes. 

I'll then open the Xcode project and switch over to MustacheHelper, and add in a helper class to make it easy to render Mustache templates. If you're unsure how this works, check out my screencast on Templating with Mustache.

```
import PerfectMustache

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

Now let's open up TILController.swift, and create a method to register its routes. For now it will contain just a single entry: if you perform a GET at the "til" path, it will call the index handler.

Let's write that next. To quickly try this out, for now now I'll return all of the acronyms as JSON. If there's an error, I'll return that instead.

```
import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

final class TILController {

  var routes: [Route] {
    return [
      Route(method: .get, uri: "/til", handler: indexView),
    ]
  }

  func indexView(request: HTTPRequest, response: HTTPResponse) {
    do {
      let json = try AcronymAPI.all()
      response.setBody(string: json)
        .setHeader(.contentType, value: "application/json")
        .completed()
    } catch {
      response.setBody(string: "Error handling request: \(error)")
        .completed(status: .internalServerError)
    }
  }

}
```

Next, I'll open main.swift, create an instance of my controller, and call the addRoutes method.

```
let til = TILController()
server.addRoutes(Routes(til.routes))
```

Build and run, and nice - I can go to /til see the list of acronyms. 

Now that we know we have a working route, let's pretty it up by using Skeleton. 

To get skeleton, we can just go to getskeleton.com. 

```
http://getskeleton.com/
```

Before I download it though, let me give you a quick overview of how it works.

The first thing to point out is that it comes with a handy grid system. The basic idea is Skeleton splits the page into 12 columns, and whenever you want something to be in particular column, you just surround it by a div tag that specifies the number of columns. Every time you want a new row, you use the row class, and you put the entire page in a container.

Next, it comes with some basic typography to make your pages look pretty decent. Note that it uses a special web font called Raleway served by Google.

It also has some default styling for buttons - basically either apply the button class, or use the button tag, or an input tag of type submit or button, and it will be applied automatically. There are also blue "primary" buttons that you can get by applying the button-primary class.

There's also some nice default styling for forms. It's all built in, except do notice there's a u-full-width tag you can use to make an element fill up the entire width of its container.

Finally, there's some other stuff like list styling, code styling, tables, and media queries.

Allright - let's so go to the top and click Download. Then, I'll open a my project folder and create a new directory called webroot, and move the entire CSS directory into it.

Now I need to configure Perfect to serve files in the webroot directory. To do this, I'll open main.swift and set the server's document root to the my project directory.

```
server.documentRoot = "webroot"
```

I'll also edit the scheme, and set the working directory to the webroot directory.

I'll now build and run, and I verify this by browsing to /css/skeleton.css:

```
http://localhost:8080/csss/skeleton.css
```

And nice - there's my file.

Now that we have skeleton available, let's create a mustache template uses it.  But first let's regenerate the Xcode project so it detects ths new directory. 

I'll create a new mustache template called index.mustache, and I'll turn on syntax highlighting real quick.

First, I'll add the standard tags to start a HTML document. Then I'll import the two CSS files provided by skeleton, and import a google font that Skeleton requires.

Then, I'll add a container for the page, add the first row, and make it full-width. Inside, I'll put a header for the web app.

```
<!DOCTYPE html>
<html lang="en">
<head>
  <title>TIL</title>  
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/css/normalize.css">
  <link rel="stylesheet" href="/css/skeleton.css">
  <link href="//fonts.googleapis.com/css?family=Raleway:400,300,600" rel="stylesheet" type="text/css">
</head>
<body>
  <div class="container">
    <div class="row">
      <div class="u-full-width">
        <h2>TIL: Today I Learned <small>Perfect Web Service</small></h2>
      </div>
    </div>

    <!-- TODO -->

  </div>
</body>
</html>
```

Next, let's fill in the TODO ot render a list of acronyms. 

We're going to assume we're passed an array of acronym objects, in a parameter called "acronyms". So first we'll loop through the list of acronyms, and create a row for each.

First, we'll create a three-wide column, and put the short version of the acronym. Again, we're assuming that the objects in the array contain a property called short. 

Second, we'll create a six-wide column, and put the long version of the acronym.

Third, we'll create a final three-wide column, that is just a placeholder for now.

This sums up to 12 columns, which is what Skeleton expects, so we're good.

```
{{#acronyms}}
<div class="row">
  <div class="three columns">
    <h5><span>{{short}}</span></h5>
  </div>
  <div class="six columns">
    <p><span>{{long}}</span></p>
  </div>
  <div class="three columns">    
  </div>
</div>
{{/acronyms}}
```

Now, we need to update our controller to serve this template. First I'll open TILController.swift, and add a property to help us know where the templates are stored.

```
let documentRoot = "./webroot"
```

Next, I'll delete the placeholder JSON we were returning earlier.

Remember, our template is assuming that we pass it a dictionary of acronyms, in a parameter called "acronyms". So let's create a Mustache map type, and set the acronyms value to all of the acronyms in the database, returned as a dictionary.

Finally we call mustacheRequest, passing the request, response, our MustacheHelper, and the path of the template we just created.

```
var values = MustacheEvaluationContext.MapType()
values["acronyms"] = try AcronymAPI.allAsDictionary()
mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/index.mustache")
```

Build and run, and go to /til - and awesome, we see a nice looking list of acronyms styled with Skeleton!

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to easily beautify your Perfect web apps using Skeleton. You can apply these same techniques to any CSS boilerplate library you choose, or even your own CSS. If you want to review any of the code, you can download the completed project below.

You've learned a lot about Perfect at this point, and you're probably eager to put together everything you've learned into a complete web app. Well good news - that is the subject of my next screencast!

I hope that you enjoy Skeleton as much as I do, and I hope that you can use it to give your next project some solid... bones. I'm out!