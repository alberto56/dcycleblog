---
layout: post
title:  "An approach to automating Drupal accessibility tests"
date:   2019-04-07
tags:
  - blog
  - planet
id: 2019-03-14
permalink: /blog/2019-04-07/accessibility/
redirect_from:
  - /blog/2019-04-07/
---

Accessibility tests can be automated to a degree, but not completely; to succeed at accessibility, it needs to be a mindset shared by developers, UX and front-end folks, business people and other stakeholders. In this article, we will attempt to run tests and produce meaningful metrics which can help teams who are already committed to produce more accessible websites.

Premise
-----

Say your team is developing a Drupal 8 site and you have decided that you want to reduce its accessibility issues by 50% over the course of six months.

In this article, we will look at a subset of accessibility which can be automatically checked -- color contrast, placement of tags and HTML attributes, for example. Furthermore, we will only test the code itself with some dummy data, not actual live data or environment. Therefore, if you use the approach outlined in this article, it is best to do so within a global approach which includes stakeholder training; and automated and manual monitoring of live environments, all of which are outside the scope of this article.

Approach
-----

Your team is probably perpetually "too busy" to fix accessibility issues; and therefore too busy to read and process reports with dozens, perhaps hundreds, of accessibility problems on thousands of pages.

Instead of expecting teams to process accessibility reports, we will use a **threshold** approach:

First, **determine a standard** towards which you'd like to work, for example WCAG 2.0 AA is more stringent than WCAG 2.0 A (but if you're working on a U.S. Government website, WCAG 2 AA is mandated by the Americans with Disabilities Act). Be realistic as to the level of effort your team is ready to deploy.

Next (we'll see how to do this later), **figure out which pages** you'd like to test against: perhaps one article, one event page, the home page, perhaps an internal page for logged in users.

In this article, to keep things simple, we'll test for:

* the home page;
* an public-facing internal page, /node/1;
* the /user page for users who are logged in;
* the node editing form at /node/1/edit (for users who are logged in, obviously).

Running accessibility checks on each of the above pages, we will end up with our **baseline threshold**, the current number of errors, for example this might be:

* 6 for the home page
* 6 for /node/1
* 10 for /user
* 10 for /node/1/edit

We will then make our tests fail if there more errors on a given page than we allow for. The test should pass at first, and this approach meets several objectives:

* First, have an idea of the state of your site: are there 10 accessibility errors on the home page, or 1000?
* Fail immediately if a developer opens a pull request where the number of accessibility errors increases past the threshold for any given page. For example, if a widget is added to the /user page which makes the number of accessibility errors jump to 12 (in this example), we should see a failure in our continuous integration infrastructure because `12 >= 10`.
* Provide your team with the tools to **reduce the threshold over time**. Concretely, a discussion with all stakeholders can be had once the initial metrics are in place; a decision might be made that we want to reduce thresholds for each page by 50% within 6 months. This allows your technical team to justify the prioritization of time spent on accessibility fixes vs. other tasks seen by able-bodied stakeholders as having a more direct business value.

Principles
-----

### Principle #1: Docker for everything

Because we want to run tests on a continuous integration server, we want to avoid dependencies. Specifically, we want a system which does not require us to install specific versions of MySQL, PHP, headless browsers, accessibility checkers, etc. All our dependencies will be embedded into our project using Docker and Docker Compose. That way, all you need to install in order to run your project and test for accessibility (and indeed other tests) is Docker, which in most cases includes Docker Compose.

### Principle #2: A starter database

In our continous integration setup, will will be testing our code on every commit. Although it can be useful to test, or monitor, a remote environment such as the live or staging site, _this is not what this article is about_. This means we need some way to include dummy data into our codebase. (Be careful not to rely on your database to move configuration to the production site -- use configuration management for that -- we only want to store dummy _data_ in our starter database; all configuration should be in code.) In our example, our starter database will contain node/1 with some realistic dummy data. This is required because as part of our test we want to run accessibility checks agains `/node/1/edit`.

A good practice during development would be that for new data types, say a new content type "sandwich", a new version of the starter database be created with, say, node/2 of type "sandwich", with realistic data in all its fields. This will allow us to add an accessibility test for /node/2, and /node/2/edit if we wish.

Tools
-----

**Don't forget, as per principle #1, above, you will never need to install anything other than Docker on your computer or CI server, so don't attempt to install these tools locally, they will run on Docker containers which will be built automatically for you.**

* **Pa11y**: There are dozens of tools to check for accessibility; in this article we've settled on Pa11y because it provides clear errors, allows the concept of a threshold above which the script fails.
* **Chromium**: In order to check a page for accessibility issues without actually having a browser open, a so-called headless browser is needed. Chromium is a fully functional browser which works on the command line and can be scripted. This works under the hood and you will have no need to install it or interact with it directly, it's just good to know it's there.
* **Puppeteer**: most accessibility tools including Pa11y are good at testing one page. Say, if you point Pa11y to /node/1 or the home page, it will generate nice reports with thresholds. However if you point Pa11y to /user or /node/1/edit it will see those pages anonymously, which is not what we want to test. This is where Puppeteer, a browser scripting tool, comes into play. We will use Puppeteer later on to log into our site and save the markup of /user and /node/1/edit as `/dom-captures/user.html` and `/dom-captures/node-1-edit.html`, respectively, which will then allow Pa11y to access and test those paths anonymously.
* And of course, **Drupal 8**, although you could apply the technique in this article to any web technology, because our accessibility checks are run against the web pages just like an end user would see them.

Setup
-----

To follow along, you can install and start [Docker Desktop](https://www.docker.com/products/docker-desktop) and [download the Dcycle Drupal 8 starterkit](http://github.com/dcycle/starterkit-drupal8site).

    git clone https://github.com/dcycle/starterkit-drupal8site.git
    cd starterkit-drupal8site
    ./scripts/deploy.sh

You are also welcome to fork the project and link it to a free [CircleCI](http://circleci.com) account, in which case continuous integration tests should start running immediately on every commit.

A few minutes after running ./scripts/deploy.sh, you should see a login link to a full Drupal installation on a random local port (for example http://0.0.0.0:32769) with some dummy data (/node/1). Deploying this site locally or on a CI server such as Circle CI is a one-step, one-dependency process.

In the rest of this article we will refer to this local environment as http://0.0.0.0:YOUR_PORT; always substitute your own port number (in our example 32769) for `YOUR_PORT`.

Introducing Pa11y
-----

We will use a Dockerized version of Pa11y, `dcycle/pa11y`, here is how it works against, say, amazon.com:

    docker run --rm dcycle/pa11y:1 https://amazon.com

Running Pa11y against a local site
-----

Developers and continuous integration servers will need to run Pa11y against a local site. We woudl be tempted to run Pa11y on 0.0.0.0:YOUR_PORT, but that won't work because Pa11y is being run inside its own container and will not have access to the host machine. You could give it access, but that raises another issue: the port is not guaranteed to be the same, which requires ugly logic to figure out the port. Instead, we will attach Pa11y to the Docker network used by our Starter site, in this case called `starterkit_drupal8site_default` (you can use `docker network ls` to list networks). Because our docker-compose.yml file defines the Drupal container as having the name `drupal` and port 80 (the default port), we can now run:

    docker run --network starterkit_drupal8site_default --rm dcycle/pa11y:1 http://drupal

This has some errors, just as we expected. Before doing anything else, type `echo $?`; this will give a non-zero code, meaning running this will make your continuous integration script fail. However, because we decided earlier that we will tolerate, for now, 6 errors on the home page, let's set a threshold of 6 (or however many errors you get -- there are 6 at the time of this writing):

    docker run --network starterkit_drupal8site_default --rm dcycle/pa11y:1 http://drupal --threshold 6

There, we've met our threshold, so we will not have a failure!

How about pages where you need to be logged in?
-----

The above solution breaks down, though, when you want to test http://drupal/node/1/edit. Although it will produce results, what we are actually checking against here is the "Access denied" page, not /node/1/edit when we are logged in. We will approach this in the following way:

* Set a random password for user 1;
* Use Puppeteer (see "Tools", above) to click around your local site with its dummy data, do whatever you want to, and, every step of the way, save the DOM (the document object model, or the current markup after it has been processed by Javascript) as a temporary flat file, named, say, http://drupal/dom-captures/user.html;
* Step 2, use Pa11y to test the temporary file we just created;

Putting it all together
-----

In our Drupal 8 Starterkit, we can test the entire process. Start by running the Puppeteer script to generate /dom-captures/user.html and /dom-captures/node-1-edit.html:

    ./scripts/end-to-end-tests.sh

Astute readers have realized by now that clicking through the site to create our dom captures has the added benefit of confirming that our site functionality works as expected, which is why I called the script `end-to-end-tests.sh`.

To confirm this actually worked, you can visit, _in an incognito window_:

* http://0.0.0.0:PORT/dom-captures/user.html
* http://0.0.0.0:PORT/dom-captures/node-1-edit.html

Yes it _looks_ like you're logged in, but you are not: these are anonymous webpages which Pa11y can check.

So if this worked correctly (and it should, because we hav it [under continuous integration](https://circleci.com/gh/dcycle/starterkit-drupal8site/tree/master)), we can run our Pa11y tests agains all these pages:

    ./scripts/a11y-tests.sh
    echo $?

You will see the errors, but because the _number of errors_ is below our threshold, the _exit code_ will be zero, allowing our Continuous integration tests to pass.

Conclusion
-----

Making a site accessible is, in my opinion, akin to making a site secure: it is not something to add to a to-do list, but rather an approach including all site stakeholders. Neither is accessibility something which can be automated; it really is a team culture. However, approaches like the one outlined in this article, or whatever works in your organization, will give teams metrics to facilitate the integration of accessibility into their day-to-day operations.

