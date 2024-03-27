---
layout: post
title: "Comparing Bootstrap, Tailwind, Flexbox, and CSS Grid"
date: 2024-01-08T14:43:30.853Z
id: 2024-01-08
author: admin
tags:
  - blog
permalink: /blog/2024-01-08/bootstrap-tailwind-flexbox-grid/
redirect_from:
  - /blog/2024-01-08/
  - /node/2024-01-08/
---

[Bootstrap](https://getbootstrap.com), [Tailwind](https://tailwindcss.com), [Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/), and [CSS Grid](https://css-tricks.com/snippets/css/complete-guide-grid/) are some approaches to achieve layouts in CSS.

To get the most out of this post, you should be familiar with CSS.

The 30 second introduction
-----

Chances are you're not familiar with all these approaches, so here's a quick demo of what each can do.

* [A very simple Bootstrap page](/static/bootstrap.html)
* [A very simple Tailwind page](/static/tailwind.html)
* [A very simple Flexbox page](/static/flexbox.html)
* [A very simple CSS Grid page](/static/grid.html)

Minimizing shipped code, and the build step
-----

Flexbox and CSS Grid are native CSS, supported by all modern browsers, so you don't need to load an external library.

Bootstrap and Tailwind, however, are external libraries. In our example above we use a CDN (content delivery network) to load the libraries. In their default configuration, are, at the time of this writing, 49kb for Bootstrap and 111kb for Tailwind (compressed).

However, this means the client ends up with a lot of unwanted CSS. You don't need to strip unwanted CSS if you're only using flexbox or CSS Grid.

So if we use Bootstrap or Tailwind, we can choose to either

* use a CDN version of the library code but have the client load a lot of unwanted CSS.
* host the library but prune it to remove unneeded CSS rules.

Here are some of the benefits and disadvantages of each approach:

### Pros and cons of using a CDN

Using a CDN means that the library you use (Bootstrap, Tailwind, or anything else) is stored outside of your sever. This might have several advantages:

* it increases the possibility of a cache-hit. For example, if a user visits site A which loads Bootstrap from a CDN, and then the user visits site B which also loads Bootstrap from a CDN, then when visiting site B, the library is already in memory.
* it reduces your server's bandwidth
* it ensures a geogrpahically close response
* you don't need to maintain or think about the script, it generally just works
* you don't need to commit code that's not your own to version control (I like to only have my own code in version control)
* you don't need a build step, simplifying deployment, especially for simple projects

Among the disadvanges

* your website won't work if the CDN is not available. For example if you don't have internet access and are doing local development on a project, it will look bad.
* if you don't have a cache hit, you are forcing your end user to load a lot of unwanted code.

TailwindCSS's [Play CDN](https://tailwindcss.com/docs/installation/play-cdn) is specifically state as "development purposes only, and is not the best choice for production".

### Pros and cons of building and pruning your CSS

Imagine your web page only uses a few CSS classes from your library (Bootstrap or Tailwind). The main advantage of using a build step to prune the library is that it will result in a small footprint and fast load time, even for larger projects.

The disadvantages have to do with a more complex workflow (which you'd probably want anyway for any medium to large project):

* All developers must be aware of how to build the project to develop locally
* Your continuous integration (CI) server must build the project before running end-to-end tests
* The build process should be as close to identical as possible on development, stage, CI and production environements.

### Stripping unwanted CSS in Tailwind

We will use [PurgeCSS](https://purgecss.com) to remove unwanted CSS from our Bootstrap CSS file. To do so, let's revisit our [simple Bootstrap page]((/static/bootstrap.html)) from above.

First, we cannot host our CSS on a CDN if we want to purge it. Instead,

### Stripping unwanted CSS in Tailwind


Resources
-----

* https://www.w3schools.com/bootstrap/
* https://www.w3schools.com/css/css_grid.asp
* https://www.w3schools.com/css/css3_flexbox.asp
* https://getbootstrap.com/docs/5.0/layout/grid/
* https://www.youtube.com/watch?v=mXB79mlAhNc
* https://medium.com/dwarves-foundation/remove-unused-css-styles-from-bootstrap-using-purgecss-88395a2c5772
* https://stackoverflow.com/a/2180401/1207752
