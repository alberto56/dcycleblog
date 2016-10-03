---
layout: post
title: Eight tips to remember on your path to automated testing
id: 52
created: 1393430169
tags:
  - blog
  - planet
permalink: /blog/52/eight-tips-remember-your-path-automated-testing/
redirect_from:
  - /blog/52/
  - /node/52/
---
Many Drupal projects now under maintenance suffer from technical debt: a lot of the functionality is in the database and outside of git, and the code lacks automated testing. Furthermore, the functionality is often brittle: a change to one feature breaks something seemingly unrelated.

As our community and our industry mature, teams are increasingly interested in automated testing. Having worked on several Drupal projects with and without automated testing, I've come to the conclusion that any line of code which is not subject to automated testing _is legacy code_; and I agree with Michael Feathers who stated in his book _[Working Effectively with Legacy Code](http://www.amazon.com/gp/product/0131177052/ref=as_li_tf_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0131177052&linkCode=as2&tag=dcycle-20)_[1] that a site with zero automated tests is a legacy site from the moment you deliver it.

But the road to automatic testing for Drupal is, as I've learned the hard way, strewn with obstacles, and first-time implementations of automated testing tend to fail. Here are a few tips to keep in mind if your team is willing to implement automated testing.

Tip #1: Use a continuous integration server
-------------------------------------------

Tests are only useful if someone actually runs them. If you don't automate running the test suite on each push to your git repo, _no one will run your tests, however good their intentions are_.

The absolute first thing you need to do is set up a continuous integration (CI) server which runs a script every time your git repo changes. To make this easier I've set up a [project on GitHub](https://github.com/alberto56/vagrant-jenkins) which uses Vagrant and Puppet to set up a quick Jenkins server tailored for use with Drupal.

Even before starting to write tests, make sure your continuous integration job actually runs on your master branch. When your project passes tests (which is easy at first because you won't have tests), your project will be marked as stable.

Notice that I mentioned the master branch: although git has advanced branching features, the only branch you should track in your CI server is your stable branch (often `master`, although for projects with more than one stable release, like Drupal itself, you may have two or three stable branches).

It is important at this point to get the team (including the client) used to seeing the continuous integration dashboard, ideally by having a monitor in a visible place ([this team](http://www.youtube.com/watch?v=3T5fEV5YHYo) even plugged Jenkins into a stop light, which really grabs attention in case of a failure). If your code is flagged as failed by your CI server, you want it to be known as soon as possible, and you want the entire team to have responsibility for fixing it immediately. Your main enemy here is failure fatigue: *if your master branch is broken, and no one is working at fixing it, you will get used to seeing failures and you will fail at implementing automated testing*.

Eventually, you will want to add value to your continuous integration job by running [Code Review](https://drupal.org/project/coder) tests, and other code analysis tools like [Pdepend](http://pdepend.org). With these kinds of tools, you can get a historical perspective on metrics like adherance to [Drupal coding standards](https://drupal.org/coding-standards), the number of lines of code per function, code abstraction, and the like. I even like to have my Jenkins job take a screenshot of my site on every push (using [PhantomJS](http://phantomjs.org)), and comparing the latest screenshot to the previous one [ImageMagick](http://www.imagemagick.org)'s `compare` utility.

Basically, any testing and analysis you can do on the command line should be done within your continuous integration job.

If done right, and if you have high confidence in your test suite, you can eventually use your CI server to [deploy continuously](http://dcycleproject.org/blog/46) to preproduction, but let's not get ahead of ourselves.

Tip #2: Test your code, not the database
----------------------------------------

Most Drupal developers I've talked to create their local development environment by bringing their git repo up to date, and cloning the production database.

They also tend to clone the production or preproduction database back to Jenkins in their continuous integration.

For me, this is the wrong approach, as I've [documented in this blog post](http://dcycleproject.org/blog/48).

Basically, any tests you write should reside in your git repo and be limited to testing what's in the git repo. If you try to test the production database, here is a typical scenario:

 * Someone will do something to your database which will break a test.

 * Your Jenkins job will clone the database, run the test, and fail.

 * Another person will make another change to the database, and your test will now pass.

You will now see a history of failures which will indicate problems outside of your code. These will be very hard to reproduce and fix.

Keep in mind that the tests you write should depend on a _known good starting point_: you should be able to consistently reproduce an environment leading to a success or a failure. Drupal's Simpletests completely ignore the current host database and create a new database from scratch just for testing, then destroy that database.

How to do this? First, I always use a [site deployment module](http://dcycleproject.org/blog/44) whose job it is to populate the database with everything that makes your site unique: enabling the site deployment module should enable all modules used by your site, and, using [Features](http://drupal.org/project/features) and related modules, deploy all views, content types, and the like, set all variables and set the default theme. The site deployment module can then be used by new developers on your team who need a development environment, and also by the CI server, _all without cloning the database_. If you need dummy content for development, you can use [Devel](https://drupal.org/project/devel)'s `devel_generate` utility, along with [this trick](https://drupal.org/node/1748302) to make your generated content more realistic.

When a bug is reported on your production site, you should reproduce it consistently in your dummy content, and then run your test against the simulation, not the real data. An example of this is the use of Wysiwyg: often, `lorem ipsum` works fine, but once the client starts copy-pasting from Word, all kinds of problems arise. Simulated word-generated markup is the kind of thing your test should set up, and then test against.

If you are involved in a highly-critical project, you might eventually want to run certain tests on a clone of your production database, but this, in my opinion, should not be attempted until you have proper test coverage and metrics for your code itself. If you do test a clone of your production database and a bug is found, reproduce the bug in a simulation, add a test to confirm the bug, and fix your code. Fixing your code to deal with a problem in production without simulating the problem first, _and testing the simulation_, just results in more legacy code.

Tip #3: Understand the effort involved
--------------------------------------

Testing is time-consuming. If your client or employer asks for it, that desire needs to come with the appropriate resources. Near the beginning of a project, you can easily double all time estimates, and the payoff will come later on.

<img src="http://dcycleproject.org/sites/dcycleproject.org/files/pyramid2.png" />

Stakeholders cannot expect the same velocity for a project with and without automated testing: if you are implementing testing correctly, your end-of-sprint demos will contain less features. On the other hand, once you have reached your sweet spot (see chart, above), the more manageable number of bugs will mean you can continue working on features.

Tip #4: Start gradually
-----------------------

Don't try to test everything at once. If your team is called upon to "implement automated testing" on a project, you are very likely to succumb to test paralysis if you try to implement it all at once.

When working with legacy sites, or even new sites for which there is pressure to deliver fast, I have seen many teams never deliver a single test, instead delivering excuses such as "it's really simple, we don't need to test it", or "we absolutely had to deliver it this week". In reality, we tend to see "automated testing" as insurmountable and try to weasel our way of it.

To overcome this, I often start a project with a single test: find a function in your code which you can run against a unit test (no database required), and write your first test. In Drupal, you can use a Simpletest Unit test (as in [this example](http://dcycleproject.org/blog/basic-unit-test)) and then run it straight from the browser.

Once you're satisfied, add this line to your CI job so the test is run on every push:

    drush test-run mytestgroup

Once that is done, it becomes easier for developers to write their own tests by adding it to the test file already present.

Tip #5: Don't overestimate how good a developer you are
-------------------------------------------------------

We all think we're good developers, and really we can't imagine anything ever going wrong with our code, I mean, _it's so elegant!_ Well, we're wrong.

I've seen really intelligent people write code which looks really elegant, but still breaks.

I've seen developers never write tests for the simple stuff because it's too simple, and never write tests for the more complex stuff because they never practiced with the simple stuff.

Even though you're positive your code is so robust it will never break, _just test it_.

Tip #6: Start with the low-hanging fruit
----------------------------------------

This is an error I made myself and which proved very painful. Consider a system with three possible use cases for the end user. Each use case uses the same underlying calls to the database, and the same underlying [pure functions](http://en.wikipedia.org/wiki/Pure_function).

Now, let's say you are using a high-level testing framework like Behat and Selenium to test the rich user interface and you write three tests, one for each use case. You think (wrongly, as we'll see) that you don't need unit tests, because whatever it is you want to test with your unit tests _is already tested by your high-level rich user interface tests_.

Don't forget, your specs also call for you to support IE8, IE9, Webkit (Safari) and Firefox. You can set up Jenkins to run the rich GUI tests via Selenium Grid on a Windows VM, and other fancy stuff.

This approach is wrong, because when you start having 5, 8, 10, 20 use cases, you will be tempted to continue just implement dozens of new, expensive rich GUI tests, and your tests will end up taking hours.

In my experience, if your entire test suite takes more than two hours to run, developers will start resenting the process and ignoring the test results, and you are back to square one.

In his book _[Succeeding with Agile](http://www.amazon.com/gp/product/0321579364/ref=as_li_tf_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321579364&linkCode=as2&tag=dcycle-20)_, Mike Cohn came up with the idea of a test pyramid, as shown in the diagram below (you can learn more about the concept [in this blog post](http://martinfowler.com/bliki/TestPyramid.html)).

<img src="http://dcycleproject.org/sites/dcycleproject.org/files/pyramid.png" />

Based on this concept, we quickly realize that:

 * Several steps are redundant among the GUI use cases.
 * The exact same underlying functionality is tested several times over.

Thinking of this from a different angle, we can start by testing our pure functions using unit tests. This will make for lightning-fast tests, and will get the team into the habit of not mixing UI functions, database functions and pure functions (for an example of what _not to do_, see Drupal's own [block_admin_display_form_submit](http://dcycleproject.org/blog/27)).

Once you have built up a suite of unit tests which actually has value, move on to the next step: tests which require the database. This requires some variation of a [site deployment module](http://dcycleproject.org/blog/44) or another technique to bring the database to a known-good starting point before you run the test; it is harder to grasp and setting up a CI job for these types of tests is difficult too. However, your team will more likely be willing to work hard to overcome these obstacles because of the success they achieved with unit tests.

All of the above can be done with Drupal's core `simpletest`.

Finally, when you are satisfied with your unit test suites and your database tests, you can move outside of Drupal and on targeted tests (not all usecases, only a few to make sure your widgets work) with Behat, Mink, Selenium, Windows/IE VMs. If you start with the fancy stuff, though, or have too much of it, the risk of failure is much greater.

Tip #7: Don't underestimate developers' ability to avoid writing tests
----------------------------------------------------------------------

If you implement all the tips you've seen until now in this article, something curious will happen: no one will write any tests. Not even you.

Here's the psychology behind not writing tests:

 * You _really_ have the intention of writing tests, you just want to get your feature working first.
 * You work hard at getting your feature ready for the end-of-sprint demo.
 * You show off your feature to the team and they like it.
 * You don't write any tests.

The above will happen to you. And keep in mind, you're actually very interested in automated testing (enough to have read this article until now!). Now imagine your teammates, who are less interested in automated testing. They don't stand a chance.

These are some techniques to get people to write tests:

The first is used by the Drupal project itself and is based on peer review of patches. If you submit a patch to core and it does not contain tests, it will not make it in. This requires that all code be reviewed before making it into your git repo's stable branch. There are tools for this, like [Phabricator](http://phabricator.org), but I've never successfully implemented this approach (if you have, let me know!).

The second approach is to write your tests before writing a new feature or fixing a bug. This is known as *test-driven development (TDD)* and it generally requires people to see things from a different angle. Here is a typical scenario of TDD:

 * A bug comes in for project xyz, and you are assigned to it.

 * You write a test for it. If you don't know something (no function exists yet, so you don't know what it's called; no field exists yet, so you don't know how to target it), just put something feasible. If you're dealing with the body field in your test, just use `body`. Try to test all conceivable [happy paths](http://en.wikipedia.org/wiki/Happy_path) _and_ sad paths.

 * Now switch modes: your goal is to make the test pass. This is an iterative process which entails writing code and *changing your test* as well (your test is code too, don't forget!). For example, perhaps the body field's machine name is not `body` but something like `field_body[`und`][0]`. If such is the case, change the test, as long as the spirit of the test remains.

The above techniques, and code coverage tools like [code_coverage](https://drupal.org/project/code_coverage) or the experimental [cover](https://drupal.org/sandbox/znerol/2004464), which I like, will help you write tests, but changing a team's approach can only be achieved through hard work, evangelizing, presentations, blogging, and the like.

Tip #8: Don't subvert your process
----------------------------------

When it becomes challenging to write tests, you might figure that, just this once, you'll not test something. A typical example I've seen of this, in project after project, is communication with outside systems and outside APIs. Because we're not controlling the outside system, it's hard to test it, right? True, but not impossible. If you've set aside enough time in your estimates to do things right, you will be able to implement [mock objects](http://en.wikipedia.org/wiki/Mock_object), making sure you test everything.

For example, in [this blog post](http://dcycleproject.org/blog/38), I demonstrate how I used the [Mockable](https://drupal.org/project/mockable) module to define mock objects to test integration between Drupal and a content deployment system.

You will come across situations where implementing testing seems very hard, but however much effort I put into implementing automated testing for something, I have never regretted it.

Bonus tip: the entire team should own the tests
------------------------------------------------------

Your tests cannot be imposed by any one member of the team if they are to succeed. Instead, agree on what should be tested during your sprint planning.

For example, some developers (myself included) like to have close to zero Drupal styling errors. Others don't really see the point of using two spaces instead of a tab. Unless you agree on what defines a failure (more than 100 minor styling errors? 1000? No threshold at all?), developers will feel resentful of having to fix it.

Because in Agile, your client is part of team as well, it is a good idea to involve them in defining what you are testing, providing them with the costs and benefits of each test. Perhaps your client doesn't know what a MySQL query is, but if told that keeping the number of queries to less than 100 on the home page (something that can be tracked automatically) will keep performance up, they will be more likely to accept the extra cost associated.

Conclusion
---------

Automated testing is about much more than tools (often the tools are quite simple to set up). The human aspect and the methodology are much more important to get your automated testing project off the ground.

[1] See Jez Humble and David Farley's _[Continuous Delivery](http://www.amazon.com/gp/product/0321601912/ref=as_li_tf_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321601912&linkCode=as2&tag=dcycle-20)_, Addison Wesley.
