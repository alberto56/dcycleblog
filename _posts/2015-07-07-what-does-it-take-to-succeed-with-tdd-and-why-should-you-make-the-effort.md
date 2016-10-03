---
layout: post
title: What does it take to succeed with TDD, and why should you make the effort?
author: admin
id: 97
created: 1436289626
tags:
  - blog
permalink: /blog/97/what-does-it-take-succeed-tdd-and-why-should-you-make-effort/
redirect_from:
  - /blog/97/
  - /node/97/
---
A few weeks ago, I participated in an online panel on the subject of Test-Driven Development as part of Continuous Discussions (#c9d9), a series of community panels about Agile, Continuous Delivery and DevOps. Watch a recording of the panel:

<iframe width="560" height="315" src="https://www.youtube.com/embed/m8YQYidmWSc?list=PLLeSO3RXTSFPATr69H4MI9mtavDF6WMH_" frameborder="0" allowfullscreen></iframe>

Continuous Discussions is a community initiative by [Electric Cloud](http://electric-cloud.com/powering-continuous-delivery/), which powers Continuous Delivery at businesses like SpaceX, Cisco, GE and E*TRADE by automating their build, test and deployment processes.

Below are a few insights from my contribution to the panel:

What are the measurable benefits of TDD?
-----

“I find it very useful to develop in two modes. You start in creative mode, where you define what needs to be done and you think about your ‘sad path’, how your system should react when things go wrong, you think about your ‘happy path’ and your edge cases. Developers need this kind of space to think about this stuff and to write it down as a test, and even think about it together as a team and write down failing tests that demonstrate what they want their system to do.

“Once those tests are in place we switch to a mode I call ‘in the zone’, in which we focus single-mindedly on fixing those tests and making them pass – that’s a less creative mode. Separating the two avoids problems of feature creep, and often if you don’t write your failing tests and your sad paths first, you don’t think about how your system should work when things go wrong. Whereas if you consciously think about it first, it becomes a test, and forces you to write code to fit all possible eventual outcomes.

“That’s a measurable benefit which is the most visible for developers. And the most visible benefit is preventing the ‘regression wall’ which happens a few months into a project, where the majority of work on a non-TDD project becomes fixing bugs, stuff that supposedly ‘worked before’ and doesn’t work anymore. When a team hits 50% of their time or more on fixing regressions, that’s what I call the ‘regression wall’ and that’s when teams start to panic and say, we should start testing, but it’s too late, they should have started testing much earlier.”

What are the challenges of TDD?
-----

“It’s not very technically challenging, it’s more about getting people into the mindset of doing testing. First of all, if you want to get into TDD – double your development time, double your lead time, that’s what it takes. So it’s not a magic bullet. Often clients who reach that regression wall think of TDD, they get a TDD consultant and they think it’s a magic bullet to make them go faster. They will go faster but first they’ll go slower because they have to pay off that technical debt. So let’s sell the clients and the stakeholders and team on that idea, going slower to go faster later on.

“Then there is ‘test paralysis’, when a team is sold on writing tests but they’re not actually writing tests, and that’s because they’re saying, this thing I’m writing is so simple and obvious that I’m not going to write a test for it, but not writing a test for the simple stuff, means that when you get to the complex stuff, you won’t have the practice to write tests. You get into this loop and then you never write any tests, it’s difficult to break that loop, it’s very psychological.”

What are the alternatives to TDD?
-----

“The only really credible alternative is writing tests after writing your code. Many clients have expressed interest in doing this, and I’ve actually never seen it work. Once you have code that supposedly ‘works’, for example you can demo it to a client, you lose all your incentive to write the tests because it works. And people need an incentive to write tests.

“Also, code is actually very different if you write it after a test and before. If you write code after you write a test it’s a lot more discrete, modular, and logical. If you write code before testing, for example to make a demo work, the code is much harder to work out.

"Other alternatives are having some QA department, which doesn’t really work either. Having done TDD for several years I would say ‘none’, there are no alternatives.”

What’s your best TDD horror story?
-----

“I do web development so we have production sites, and we sold one client on the idea of doing TDD and CI and best practices, they would have less bells and whistles and more quality. And a week before they went into user testing, they came up with all these bugs, and it was so weird that we had them, bugs in the underlying framework, and it turned out that while some of the senior people were out on vacation, there was a small bug, a junior developer logged into the production site and 'fixed' that bug, bypassing the entire process, and introducing 10 major regressions at the same time.

“It goes to show two things – the value of TDD, the fact that this developer is used to working this way without thinking about regressions and testing: if we hadn’t been doing TDD, there wound really have been these 10 regressions in our code. Also, TDD is part of a quality ecosystem, including CI and best practices, having the production server under lock down at all times, nobody should have permission to change the production site under any circumstances. In our case we gave this permission and I spent a week trying to solve the emerging problems until I realized there was that change on production, subverting our process.”
