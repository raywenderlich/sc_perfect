## Server Side Swift with Perfect: Making a Web App (1286 words, ~5.8 min)

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how you can make a simple database-driven web app with Perfect.

To get the most out of this screencast, it would help to understand the basics of working with Perfect - specifically the basics of routing, templating, persistence, and controllers. If you're new on any of that, check out my other screencasts that cover these topics.

Today, we're basically going to put all of that together to create a simple web app called TIL - or Today I Learned. It will help me keep track of different acronyms - like BRB or AFK - and what they mean, like Be Right Back, or Away From Keyboard. A big shout-out to Audrey Tam for the idea behind this web app.

# Before recording

Don't forget to update working directory of project

# Demo

I have a simple project here where I've already done three things:

  * First, I created a model object for the Acronyms that we'll be storing in this web app. It has two properties to store the short and long versions of the Acronym - for example short might hold BRB, and long might hold Be Right Back. I've made this object derive from PostgresStORM, which the class you should derive from in StORM to store an object in a Postgres database. I've also implemented the required method to return the database table corresponding to this model object, and a method to convert a row of data into an object. The rest are various helper methods to make life easier.
  
  * Second, I've configured my app to use a database. Specifically I'm using PostgreSQL here, but everything we'll do in this screencast applies to any database provider you might prefer.

  * Third, I've set up a controller with a single route for the index. This displays a simple mustache template called index, which loops through the acronyms and displays each one. Note it's using a CSS boilerplate library called Skeleton to beautify the page a bit using a grid system.

If I build and run and navigate to the index page, this is what I see so far - basically a list of the acronyms in the database.

## Interlude

This is a good start, but so far the app isn't very interactive. In this screencast, we'll make it into a fully interactive web app by doing two things: 

  * First, we'll add the ability to add new acronyms.
  * And Second, we'll add the ability to delete acronyms.

To add new acronyms, all we need to do is add an embedded form on the page that gathers the short and long version of the acronym from the user. Back in our controller, we'll add a new route looking for a POST to a certain path, we'll pull out the data from the POST, and create a new entry in the database. Let's see how it looks. 

## Demo  
 
First let's create the HTML for the form. To do this, I'll open up index.mustache, create a new row, and make it full width. I'll create a heading here that says Add New Acronym. 

Next I'll create a form that will submit a POST to /til. I'll create a new row, and the first column will be three-wide. This is where you'll enter the short form of the acronym, so I'll give it a label, and add an input field named "short" that fills up the entire column.  

Next I'll create another column with more space - 9 columns wide this time. This is where you'll enter the long form of the acronym, so I'll give it a label, and an input field with the name "long" that also fills up the entire column. 

```
<div class="row">
  <div class="u-full-width">
    <h4>Add New Acronym</h4>
  </div>
</div>

<form action="/til" method="post">
  <div class="row">
    <div class="three columns">
      <label>Acronym</label>
      <input name="short" class="u-full-width" placeholder="short form e.g. FTW" />
    </div>
    <div class="nine columns">
      <label>Long Form</label>
      <input name="long" class="u-full-width" placeholder="long form e.g. For the Win" />
      <input class="button-primary" type="submit" value="Save Acronym">
    </div>
  </div>
</form>
```

If I build and run, and refresh the page - I see the new form.

However, this form won't do anything yet, because I haven't yet added a route to handle the post. To fix this, I'll open TILController.swift and add a new route to handle a post to "/til":

```
Route(method: .post, uri: "/til", handler: addAcronym),
```

Then, implement the addAcronym handler. I'll check the post data to look for a short and long value - remember, we set up our HTML input elements to use these names. If they aren't there, we'll abort.

Next, I'll create a new Acronym object with these values using a helper method in the Acronym API. If it works, I want to refresh the web page. I could copy and paste the code from our index route, but there's a better way - simply redirect the browser to the index page. This is easy with Perfect - just set a header with the location set to where you want to go to, and return a status of moved permanently.

```
func addAcronym(request: HTTPRequest, response: HTTPResponse) {
  do {
    // 1
    guard let short = request.param(name: "short"), let long = request.param(name: "long") else {
      response.completed(status: .badRequest)
      return
    }
    // 2
    _ = try AcronymAPI.newAcronym(withShort: short, long: long)
    // 3
    response.setHeader(.location, value: "/til")
      .completed(status: .movedPermanently)
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}
```

Now I can build and run, and try entering a new acronym into the web app - and nice, it works and shows up on the page!

## Interlude

Now our web app can list and create acronyms - but there's one step left - adding the ability to delete acronyms.

This is a review of the techniques we've done already, so this should be pretty quick.

## Demo

Back in index.mustache, I'll fill in that three column section to have a form that posts to a specially formatted URL. It will be acronyms, then the ID of the acronym to delete, then delete. I just chose this URL scheme because it seemed to make sense to me, but you could design it differently if you'd like.

Inside, I'll just put a button that says delete.

```
<div class="three columns">
  <form action="/til/{{id}}/delete" method="post">
    <input type="submit" value="Delete"/>
  </form>
</div>
```

Next I'll open TILController.swift, and add a new route looking for a post to /til/id/delete. The second parameter will be the id of the acronym to update, so we incidcate this by putting it in curly braces so Perfect can store the id away for us.

```
Route(method: .post, uri: "/til/{id}/delete", handler: deleteAcronym)
```

Next I'll write the handler. It's pretty simple: I get the ID from the url variables, and return an error if it's not there. Then I use the acronym API to delete the acronym, and redirect to til. 

```
func deleteAcronym(request: HTTPRequest, response: HTTPResponse) {
  do {  
    guard let idString = request.urlVariables["id"],
      let id = Int(idString) else {
      response.completed(status: .badRequest)
      return
    }
    try AcronymAPI.delete(id: id)
    response.setHeader(.location, value: "/til")
      .completed(status: .movedPermanently)
  } catch {
    response.setBody(string: "Error handling request: \(error)")
      .completed(status: .internalServerError)
  }
}
```

I'll build and run, and try deleting some acronyms - and nice, it works!

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to create a simple web app using Vapor. If you want to review any of the code, you can download the completed project below.

I hope you enjoyed learning how to make this simple web app with Perfect - and I'll TTYL!