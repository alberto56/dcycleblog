---
layout: post
title:  "When not to use Drupal"
date:   2016-10-02
tags:
  - planet
  - blog
id: 2016-10-02
permalink: /blog/2016-10-02/when-not-to-use-drupal/
redirect_from:
  - /blog/2016-10-02/
---

Unless you work exclusively with Drupal developers, you might be hearing some criticism of the Drupal community, among them:

 * We are almost cult-like in our devotion to Drupal;
 * maintenance and hosting are expensive;
 * Drupal is really complicated;
 * we tend to be biased toward Drupal as a solution to any problem (the [law of the instrument](https://en.wikipedia.org/wiki/Law_of_the_instrument)).

It is true that Drupal is a great solution in many cases; and I love Drupal and the Drupal community.

But we can only grow by getting off the Drupal island, and being open to objectively assess whether or not Drupal is right solution for a given use case and a given client.

> "if you love something, set it free" —Unknown origin.

Case study: the Dcycle blog
-----

I have built my entire career on Drupal, and I have been accused (with reason) several times of being biased toward Drupal; in 2016 I am making a conscious effort to be open to other technologies and assess my commitment to Drupal more objectively.

The result has been that I now tend to use Drupal for what it's good at, data-heavy web applications with user-supplied content. However, I have integrated other technologies to my toolbox: among them [node.js](https://nodejs.org/en/) for real-time websocket communication, and [Jekyll](http://jekyllrb.com) for sites that don't need to be dynamic on the server-side. In fact, these technologies can be used alongside Drupal to create a great ecosystem.

[My blog](http://dcycleproject.org) has looked like this for quite some time:

<img alt="Very ugly design." src="http://blog.dcycle.com/assets/img/ugh.png" />

It seemed to be time to refresh it. My goals were:

 * Keeping the same paths and path aliases to all posts, for example `blog/96/catching-watchdog-errors-your-simpletests` and `blog/96` and `node/96` should all [redirect to the same page](http://blog.dcycle.com/blog/96/catching-watchdog-errors-your-simpletests);
 * Keep comment functionality;
 * Apply an open-source theme with minimal changes;
 * It should be easy for myself to add articles using the [markdown syntax](https://guides.github.com/features/mastering-markdown/);
 * There should be a contact form.

My knee-jerk reaction would have been to build a Drupal 8 site, but looking at my requirements objectively, I realized that:

 * Comments can easily be exported to [Disqus](https://disqus.com) using the [Disqus Migrate](https://www.drupal.org/project/disqus_migrate) module;
 * For my contact form I can use [formspree.io](https://formspree.io/);
 * Other than the above, there is no user-generated content;
 * Upgrading my blog between major versions every few years is a problem with Drupal;
 * Security updates and hosting require a lot of resources;
 * Backups of the database and files need to be tested every so often, which also requires resources.

I eventually settled on moving this blog away from Drupal toward [Jekyll](http://jekyllrb.com), a static website generator which has the following advantages over Drupal for my use case:

 * What is actually publicly available is static HTML, ergo no security updates;
 * Because of its simplicity, testing backups is super easy;
 * My site can be hosted on GitHub using GitHub pages for free (although HTTPS is not supported yet for custom domain names);
 * All content and structure is stored in my git repo, so adding a blog post is as simple as adding a file to my git repo;
 * No PHP, no MySQL, just plain HTML and CSS: my blog now feels lightning fast;
 * Existing free and open-source templates are more plentiful for Jekyll than for Drupal, and if I can't find what I want, it is easier to convert an HTML template to Jekyll than it is to convert it to Drupal (for me anyway).
 * Jekyll offers plugins for all of my project's needs, including the [Jekyll Redirect Form](https://github.com/jekyll/jekyll-redirect-from) gem to define several paths for a single piece of content, including a canonical URL (permalink).

In a nutshell, Jekyll works by regenerating an entirely new static website every time a change is made to underlying structured data, and putting the result in a subdirectory called `_site`. All content and layout is structured in the directory hierarchy, and no database is used.

Exporting content from Drupal to Jekyll
-----

Depending on the complexity of your content, this will likely be the longest part of your migration, and will necessitate some trial and error. For the technical details of my own migration, see my blog post [Migrating content from Drupal to Jekyll](http://blog.dcycle.com/blog/2016-09-30/migrating-drupal-jekyll/).

What I learned
-----

I set out with the goal of performing the entire migration in less than a few days, and I managed to do so, all the while learning more about Jekyll. I decided to spend as little time as possible on the design, instead reusing brianmaierjr's open-source [Long Haul Jekyll theme](https://github.com/brianmaierjr/long-haul). I estimate that I have managed to perform the migration to Jekyll in about 1/5th the time it would have taken me to migrate to Drupal 8, and I'm saving on hosting and maintenance as well. Some of my clients are interested in this approach as well, and are willing to trade an administrative backend for a large reduction in risk and cost.

So how do users enter content?
-----

Being the only person who updates this blog, I am confortable adding my content (text and images) as files in Github, but most non-technical users will prefer a backend. A few notes on this:

 * First, I have noticed that even though it is possible for clients to modify their Drupal site, many actually do not;
 * Many editors consider the Drupal backend to be very user-unfriendly to begin with, and may be willing instead of it to accept the technical Github interface and a little training if it saves them development time.
 * I see a big future for Jekyll frontends such as <a href="http://prose.io/">Prose.io</a> which provide a neat editing interface (including image insertion) for editors of Jekyll sites hosted on GitHub.

Conclusion
-----

I am not advocating replacing your Drupal sites with Jekyll, but in some cases we may benefit as a community by adding tools other than the [proverbial hammer](https://en.wikipedia.org/wiki/Law_of_the_instrument) to our toolbox.

Static site generators such as Jekyll are one example of this, and with the interconnected web, making use of Drupal for what it's good at will be, in the long term, good for Drupal, our community, our clients, and ourselves as developers
