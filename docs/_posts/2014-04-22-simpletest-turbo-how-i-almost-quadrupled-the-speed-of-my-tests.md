---
layout: post
title: 'Simpletest Turbo: how I almost quadrupled the speed of my tests'
id: 58
created: 1398194111
tags:
  - blog
  - planet
permalink: /blog/58/simpletest-turbo-how-i-almost-quadrupled-speed-my-tests/
redirect_from:
  - /blog/58/
  - /node/58/
---
My development team is using a [site deployment module](http://blog.dcycle.com/blog/44) which, when enabled, deploys our entire website (with translations, views, content types, the default theme, etc.).

We defined about 30 tests (and counting) which are linked to Agile user stories and confirm that the site is doing what it's supposed to do. These tests are defined in Drupal's own Simpletest framework, and works as follows: for every test, our site deployment module is enabled on a new database ([the database is never cloned](http://blog.dcycle.com/blog/48/do-not-clone-database)), which can take about two minutes; the test is run, and then the temporary database is destroyed.

This created the following problem: because we were deploying our site 30 times during our test run, a single test run was taking over 90 minutes. Furthermore, we are halfway into the project, and we anticipate doubling, perhaps tripling our test coverage, which would mean our tests would take over four hours to run.

Now, we have a Jenkins server which performs all the tests every time a change is detected in Git, but even so, when several people are pushing to the git repo, test results which are 90 minutes old tend to be harder to debug, and developers tend to ignore, subvert and resent the whole testing process.

We could combine tests so the site would be deployed less often during the testing process, but this causes another problem: tests which are hundreds of lines long, and which validate unrelated functionality, are harder to debug than short tests, so it is not a satisfactory solution.

When we look at what is taking so long, we notice that a majority of the processing power goes to install (deploy) our testing environment _for each test_, which is then destroyed after a very short test.

Enter [Simpletest Turbo](https://drupal.org/project/simpletest_turbo), which provides very simple code to _cache_ your database once the setUp() function is run, so the next test can simply reuse the same database starting point rather than recreate everything from scratch.

<img src="http://blog.dcycle.com/sites/blog.dcycle.com/files/screen_shot_2014-04-22_at_3.13.55_pm.png" />

Although Simpletest Turbo is in early stages of development, I have used it to almost _quadruple the speed of my tests_, as you can see from this Jenkins trend chart:

<img src="http://blog.dcycle.com/sites/blog.dcycle.com/files/screen_shot_2014-04-22_at_3.14.08_pm.png" />

I know: my tests are failing more than I would like them to, but now I'm getting feedback every 25 minutes instead of every 95 minutes, so failures are easier to pinpoint and fix.

Furthermore, fairly little time is spent deploying the site: this is done once, and the following tests use a cached deployment, so we are not merely speeding up our tests (as we would if we were adding hardware): we are streamlining duplicate effort. It thus becomes relatively cheap to add new independent tests, because they are using a cached site setup.
