## Server Side Swift with Perfect: Introduction to Perfect Assistant

Hey what's up everybody, this is Ray. In today's screencast, I'm going to show you how you can use the Perfect Assistant to make  server side swift development with Perfect even easier.

Perfect Assistant is a free Mac app developed by PerfectlySoft that automates common devleopment tasks with Perfect. It helps you easily set up new projects based on templates, easily add different Perfect packages and dependencies to your project, build and run your project on Linux, and even deploy your app to Amazon EC2 or Google Cloud.

In this screencast, we're going to focus specifically on using Perfect Assistant to create and configure projects, and build and run your projects on Linux. We'll save deployment for a separate screencast, as it's a bigger topic. Let's dive in!

## Demo

The first step is to download Perfect Assistant, which you can do at perfect.org/en/assistant. Just open the DMG and drag it into your Applications folder.

```
https://www.perfect.org/en/assistant/
```

Open Perfect Assistant. You might get a security warning - if so go to System Preferences\Security and Privacy, unlock it, and click Open Anyway, and accept the prompts.

You'll see this welcome screen with options to creat various kinds of projects, or set up web deployments. Let's start by seeing how you can use Perfect Assistant to work with Perfect projects.

Click Create New Project, and you'll see a bunch of templates appear in this top area. 

* **Perfect Template App**: is basically a Hello, Perfect project. It imports Perfect and adds a single test route in there for you.
* **Empty Executable Project**: is great if you want to start from scratch with a command line app. It is the equivalent of calling `swift package init --type executable` on the command line.
* Simlarly, **Empty Library Project**: is great if you want to create a reusable library - in other words a Package - that is used within your Perfect project. It's the equivalent of `swift package init`.
* **Custom Repository URL**: allows you to enter a repository URL - for example, the URL of a repository on GitHub - and automatically pulls it down for you. This is handy if you want to try out an example you find online quickly.
* **Perfect Template App Engine**: is a modified version of the Hello, Perfect template for use with Google App Engine.

Below this, you'll see that you can also try out several example projects provided by Perfect. I've found reviewing these projects is a great way to learn Perfect - or to get a quick start on doing something specific. I encourage you to pull these down and play around with them.

To demonstrate some features of Perfect Assistant, let's choose Empty Executable Project, and click Next. I'll choose a folder for this project, and then I have to click "New Folder" and create a subdirectory with the name I want for this project. Let's call it hello-perfect-assistant, and then click Open.

Based on your folder name, Perfect Assistant will automatically suggest a project name to match, but feel free to change it. There's also a checkbox to integrate Linux builds with your Xcode project. This is one of the most handy features of Perfect Assistant, because it allows you to quickly make sure that your Perfect projects will compile on both macOS and Linux during development, instead of finding this out at a late stage. For now I'll leave this unchecked though - we'll enable it later in this screencast.

I'll click Save, and Vapor will create a project based on the empty executable project template I selected, and auto-generate an Xcode project for it. I now see a new screen, with a bunch of things I can do on the project.

Over on the left hand side, there are some handy utilities. 

  * The first one quickly opens the project directory in Finder. 
  * The second option opens a Terminal to the project directory.
  * The third option opens the Xcode project. 

The second section contains some options to build, deploy, and clean your project.
  
  * The first one lets me build locally - on macOS that is. This is handy if you don't want to build it from Xcode for whatever reason.
  * The second one builds it on Linux. For this one to work, you need to have Docker installed on your machine - I'll show you how to do this later.
  * The third option deploys your project to Amazon EC2 or Google Cloud. I'll show you how that works later.
  * The fourth option cleans yoru project directory.

The third section contains some options to quickly run your projects and tests on Linux or locally. For example, if I click the Run Local Exe button, it opens up a new terminal and runs my project - I see "Hello World" printed on the screen.

The fourth section lets you regenerate your Xcode project. When doing Server Side Swift development, I never add new files to the Xcode project within Xcode itself - instead I add them with Terminal or Finder, and regenerate the Xcode project. So this is something I use often. The integrate button sets up your Xcode project to automatically trigger a Linux build upon every build of your project.

The fifth and final section allows you to delete this project from the list of projects in Perfect Assistant. Don't worry it won't delete the project itself - it will just remove it from this list in the sidebar and delete any metadata Perfect Assistant made for your project, such as Docker images.

Over on the right side, you can easily add dependencies on various Perfect packages that are available. This saves you from having to edit Package.swift all the time. To show you how this works, I'll drag HTTPServer from the bottom up to the top. I can specify an exact version to use if I want, but I'll leave it as the default of 2.x.x. I'll make sure "automatically integrate Xcode when regenerating project" is unchecked because I don't want my compile times to be longer - I'll just build Linux manually when I want. Then I'll click Save Changes, which will cause Perfect to automatically pull down the packages and re-generate the Xcode project. 

I'll go back to my Xcode project and add some test code to verify this works:

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
  request, response in
  response.setBody(string: "Hello, Perfect!")
    .completed()
})
server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
```

I'll switch to the second target, build and run, and navigate to localhost:8080. It works!

## Interlude

At this point, Perfect Assistant has already given us a nice benefit in that it's save us time from having to generate the executable and Xcdoe project on the command line, or editing Package.swift.

But one of the biggest benefit is Perfect Assistant's ability to easily test your Linux builds on your local machine. Let's take a look at that next.

## Demo

In the Welcome panew of Perfect Assistant, if you don't have Docker installed, you'll see a button that says "Install Docker Now." I'll click that button, and it will begin to download Docker. Once it finishes, I'll drag it into my Applications folder, and then open Docker.

A popup will appear - I'll go ahead and click OK, and enter my password. After a bit, it starts up.

Now I can go back to my project, and click Build\Linux to see if it compiles OK on Linux. It's pretty cool what's happening behind the scenes - it uses Docker to set up a new Ubuntu Linux image, installs Swift 3 and other Perfect dependencies on the Linux image, transfers the source code over, builds the binaries, and transferrs the resulting binaries back to my local machine. After the compile is complete, I see a success message.

I can test the linux build out locally by clicking Run\Linux EXE. Again, it's using "docker run" to run the "hello-perfect-assistant" binary on the Ubuntu image. Again I can visit localhost:8080 and it works as befor - but I've now proven that my web app works on both macOS and Linux.

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how you can use Perfect Assistant to make working with Perfect projects easier.

In the next screencast, I'll show you how you can use Perfect Assistant to easily deploy your Perfect apps on Amazon EC2.

You know, all this talk about assistants reminds me of that time an office assistant was throwing darts at a picture of her boss. Then the phone rings, and it's the boss! The boss says "what are you doing right now?" and the assistant says "missing you." Allright - I'm out!