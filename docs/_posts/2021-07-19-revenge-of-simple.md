---
layout: post
title: The Revenge of Simple
date: 2021-07-19T14:43:30.853Z
id: 2021-07-19
author: admin
tags:
  - blog
permalink: /blog/2021-07-19/revenge-of-simple/
redirect_from:
  - /blog/2021-07-19/
  - /node/2021-07-19/
---
All public websites work the same way; clients request a URL and, as a response, get some standard HTML, CSS, JavaScript and image files.

If you are building the next Tinder or Reddit or Yelp, things are a bit more complex. You need a database, security policies, user management, PHP or Node.js servers and so on. **If that is your case, this article is not for you!**

However, if all your traffic except content administrators is public and anonymous (that is, users don't create accounts), **you are throwing money down the drain if you are using a CMS like Drupal or Wordpress**.

### Wordpress, Drupal, Node.js: the wrong solution for the wrong problem

You are paying top dollar to develop, maintain, update, host and cache these incredibly complex and attack-prone systems (don't calculate your costs right now, it will depress you).

The _only reason you need these systems_ is to have a nice CMS-type backend, something like this:

![A simple backend interface with Wysiwyg](/assets/uploads/netlify-cms-backend.jpg "A simple backend interface with Wysiwyg")

Think about that:

* You're maintaining a 24/7/365 complex unversioned database
* You need to manage backups
* Because your setup is so inefficient, you need complex front-end caching if you have any volume of visitors
* You need to manage security updates for your CMS

**All that so that you can go in and have a Wysiwyg editor once a year.**

### How often do you use your administrative backend?

Whether you're the only editor of your website, making changes once a year; or there are ten of you making changes several times a day, **it simply is more cost-effective to use a modern client-side CMS**.

Simply put, you have two options:

* Host a CMS on a webserver available 24/7/365.
* Use your site editors' computers to power the CMS **only when they need it**.

Which do you think is cheapest?

### Yeah but I'm too invested in Wordpress/Node/Drupal. I can't change everything now

Bad news, Jack: Drupal, Wordpress and their ilk are constantly publishing security updates; and worse still: end-of-life advisories which force you to make major changes whether you like to or not.

* [Drupal 7 will reach end-of-life in November of 2023](https://www.drupal.org/psa-2022-02-23)
* [Drupal 8 end-of-life on November 2, 2021](https://www.drupal.org/psa-2021-2021-06-29)
* [Wordpress 5.6 PHP end life: How to upgrade to PHP 7](https://strategynewmedia.com/wordpress-php-end-life/)

(That's not a typo, by the way: Drupal 8 will reach end-of-life two years before Drupal 7.)

Now, take a long hard look at the above links. **You are running a business, I am willing to guarantee that you do not care about end-of-life advisories**.

### Pro tip: your competitors are moving to a much cheaper, better approach to manage public websites

While you are discussing end-of-life advisories, security updates and web hosting options with consultants,

* you are paying top dollar to web experts, **money which your competitors are investing into their business**.
* you are spending precious time on topics which have zero bearing on your business, **time which your competitors are spending on improving their products and services**.

### So what is this approach?

As a reputable, growing business, your front-end web solution needs to be:

* fully open source
* fully standards-based
* fully exempt from vendor lock-in
* fully customizable

The approach is called JAMstack, and top brands around the world are using it.

### How do I move to JAMstack?

You can hire a development team to move your properties to JAMstack, but at Dcycle we have found that most businesses prefer a **subscription-based model** with **predictable monthly costs**.

If your monthly public facing website management budget is $500 or above, [contact us](http://blog.dcycle.com/contact/) if you'd like to schedule a one-hour call to discuss how we can move your web properties to a fully customizable, zero-vendor-lock-in enterprise subscription model.

If you're more of a DIY type, do a web search for migrating from Drupal or Wordpress or Node.js to JAMstack. Before you decide to go the DIY route, though, do yourself a favour and read [Common Small Business Mistake: The Do-It-Yourself Attitude (April 30, 2020) by Ana Fejzagic Livancic, on LinkedIn](https://www.linkedin.com/pulse/common-small-business-mistake-do-it-yourself-attitude-ena/).

Either way, you're on a path to never hear about databases, security updates or end-of-life advisories again. And focus on your business.
