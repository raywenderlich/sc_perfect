## Server Side Swift with Perfect: Deploying with Perfect Assistant

Hey what's up everybody, this is Ray. In today's screencast, I'm going to show you how you can use Perfect Assistant to easily deploy your server side swift with Perfect apps to Amazon EC2.

Perfect Assistant is a free Mac app developed by PerfectlySoft that automates common development tasks with Perfect. It helps you set up new projects based on templates, easily add different Perfect packages and dependencies to your project, build and run your projects on Linux, and even deploy your apps to Amazon EC2 or Google Cloud.

In this screencast, we're going to focus specifically on using Perfect Assistant to deploy your apps using Amazon EC2. You don't need any experience with Amazon EC2 to follow along. Let's dive in!

## Before recording

Try to uninstall awscli
Log out of aws.amazon.com

## Demo

To deploy to EC2, you'll first need an Amazon AWS account. If you don't have one already, you can go to aws.amazon.com and sign up for an account in the Free Tier. Don't worry, the Free Tier should be more than enough for this screencast.

I've already created a fresh AWS account for this screencast, so I'll just log in as that.

```
https://aws.amazon.com/
```

You'll also need to install the amazon command line tools. To do this, just visit aws.amazon.com/cli and follow the instructions in the sidebar. By the way, when I first tried this on El Capitan I got an erorr, but I just added  "--ignore-installed six" at the end of the command line like this and it worked for me.

```
https://aws.amazon.com/cli/
pip install awscli --ignore-installed six
```

Next I need to configure the aws command line tools to connect to my new AWS account.

To do this, I'll log onto the AWS console at aws.amazon.com, and open the Identity and Access Management console - IAM for short. This allows you to configure users and permissions on your EC2 account. In the navigation pane, I'll click Users, and then click add user. I'll name this perfect, choose Programmatic access as the access type, and click Next for Permissions.

I want to create a new group for this user that gives it full access to EC2. To do this, I'll click create group, name the group ec2-full-access, select the pre-made AmazonEC2FullAccess policy, and click Create Group. I'll then click Next, and Create user. 

This next page is very important, because it gives you the access key ID and secret access key you'll need to configure the amazon command line tools and Perfect Assistant later. Copy these somewhere secure, and click Close when you're done. I'll do this offline.

```
https://aws.amazon.com/
```

Back in Terminal, I'll type aws configure. This will ask for my access key ID and secret access key; I'll enter this offline.

```
aws configure
```

Let's test that this works by typing aws ec2 describe-instances. I see an empty list here, which makes sense because I haven't configured any ec2 servers yet. 

```
aws ec2 describe-instances
```

When you create a new instance using Amazon EC2, Amazon asks you to provide a public/private keypair. This is can configure your new instance with this keypair, so that you can log in via SSL.

So let's create a keypair to use. I'll use ssh-keygen to create a rsa key named perfect-key, and save it off to my ssh directory. I'll then use the amazon command line to import the key pair, giving it a name "perfect-key" and setting the "material" of the key to the file I just created the private key in.

```
ssh-keygen -t rsa -C "perfect-key" -f ~/.ssh/perfect-key
aws ec2 import-key-pair --key-name "perfect-key" --public-key-material file://$HOME/.ssh/perfect-key.pub
```

Another thing you need when you create an instance is a security group. In general, it's best to configure your security group to only allow access to the ports your web app needs.

To do this, I'll log onto Amazon EC2 and click security Groups, and create security group. For security group name I'll enter hello-perfect, and then give a description. I'll add a new inbound rule with protocol TCP, port range 8080, because that's what the web app we'll be deploying is configured to listen on, and source to anywhere. I'll also allow connections on port 22 for SSH. Finally I'll click Create.

Now let's configure Perfect Assistant to use these credentials as well. In the Welcome pane, I'll click Configure EC2 Credentials, click Create, enter perfect for the credentials name, and enter my access key id and secret key. Again I'll do this offline.

Next we need a project we want to deploy. I happen to have a simple Perfect app on my hard drive that I built in a previous screencast. So in Perfect Assistant, I'll click import project and navigate to that directory, and click Save. I'll test that it works on Linux by clicking Run\Local Exe and navigating to localhost:8080. I see Hello Perfect, which shows it's working.

```
http://localhost:8080
```

Now let's deploy this. I'll click Build\Deploy, and Create New. I'll choose amazon Web Services, and next. I'll enter perfect for the Configuration Name, note that my perfect ec2 credentials are already selected, and browse to the SSH private key I created earlier. I'll then click Add, click my hello-perfect security group, and make sure that we're using a nano instance, the perfec-key keypair, the availability zone we want, and click Launch.

After a while, I'll see success in the console. If I click reload, I see my new instance. I can also see this in the AWS dashboard. 

Now I'll just check the box for this instance in Perfect and click Save. Then, I'll click deploy, make sure the deployment configuration I created is selected, and click Deploy again. Perfect Assistant will then use an Ubuntu Linux docker image to build my project, and it will upload the binaries to the AWS instance and start them up as a service. 

Looks like it finished, so let's try this out. I'll copy the public DNS address from the AWS console, and navigate to that at port 8080 in my browser. I see Hello Perfect! I can also try out my /beers/99 route and that works as well.

```
http://ec2-54-165-232-232.compute-1.amazonaws.com:8080/
http://ec2-54-165-232-232.compute-1.amazonaws.com:8080/beers/99
```

Also, sometimes you might need to log onto your EC2 instance to diagnose problems, and so on. If you ever need to do this, you can just SSH in like this:

```
ssh -i ~/.ssh/perfect-key ubuntu@ec2-54-165-232-232.compute-1.amazonaws.com
```

[TODO: When I record this, show viewers where the binaries are uploaded to and the service that is running.]

Now that I've verified this is working, I don't need this instance anymore, so I'll terminate my EC2 instance to avoid any potential charges.

## Conclusion

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to use Perfect Assistant to easily deploy your Perfect app to Amazon EC2.

Note that this is just one of many ways to deploy a Perfect app. You can also deploy your Perfect apps using Docker, or using Google Cloud, or even Heroku. But since this is built-into Perfect Assistant, it's a nice easy way to get started when you're developing.

Did you know that Amazon got kudos for making their first web service - Amazon S3 - so easy to learn? That's why they wanted to make their next web service EC 2. 

Allright - I'm out!