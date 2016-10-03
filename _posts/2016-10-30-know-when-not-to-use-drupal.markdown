---
layout: post
title:  "When not to use Drupal"
date:   2016-10-02
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

The result has been that I now tend to use Drupal for what it's good at, data-heavy web applications with user-supplied content. However, I have integrated other technologies to my toolbox: among them node.js for real-time websocket communication, and Jekyll for sites that don't need to be dynamic.

[My blog](http://dcycleproject.org) has looked like this for quite some time, and it seemed to be time to refresh it. My goals were:

 * Keeping the same paths and path aliases to all posts, for example `blog/96/catching-watchdog-errors-your-simpletests` and `blog/96` and `node/96` should all [redirect to the same page](blog/96/catching-watchdog-errors-your-simpletests);
 * Keep comment functionality;
 * Apply an open-source theme with minimal changes;
 * It should be easy for myself to add articles using the [markdown syntax](https://guides.github.com/features/mastering-markdown/);
 * There should be a contact form.

My knee-jerk reaction would have been to build a Drupal-8 site, but looking at my requirements objectively, I realized that:

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

Exporting content from Drupal to Jekyll
-----

Depending on the complexity of your content, this will likely be the longest part of your migration, and will necessitate some trial and error. For the technical details of my own migration, see my blog post [Migrating content from Drupal to Jekyll](http://dcycleproject/blog/).

Jekyll content is just straight-up files written in Markdown, so exporting content from Drupal is not all that hard. In fact Jekyll provides [_importers_ to "Import your old & busted site or blog for use with Jekyll."](http://import.jekyllrb.com). Here is how I used the Drupal 7 importer using Docker (you don't need to install anything on your system except Docker to run these commands):

_First_, make sure you have a database dump of your Drupal 7 database; assuming your database is MySQL, if you have ssh access to the server where your Drupal site is located, and `drush` is installed on that server, you can get the database dump running something like:

    ssh me@myserver.example.com \
      "cd /path/to/my/drupal/site && \
      drush sql-dump" > ~/Desktop/my-drupal-7-database.sql

_Next_, create a local Docker container and put the database on it:

    # Run a new MySQL container.
    docker run \
      --name some-mysql \
      -e MYSQL_ROOT_PASSWORD=rootpassword \
      -d \
      mysql
    # Wait a bit for this server to fire up.
    sleep 15
    # Place the ~/Desktop/my-drupal-7-database.sql on the container
    # as data.sql
    docker cp ~/Desktop/my-drupal-7-database.sql some-mysql:/data.sql
    # Create a new database called "drupal" on the container, and import
    # the data.sql file, now on the container.
    docker exec \
      some-mysql \
      mysql -uroot -prootpassword \
      -e"CREATE DATABASE drupal"
    docker exec \
      some-mysql \
      mysql -uroot -prootpassword drupal \
      -e"source data.sql"




docker run \
   --name my-ruby \
   -v $(pwd):/my-content \
   ruby \
   /bin/bash -c "cd /my-content && \
   gem install jekyll-import && \
   gem install sequel && \
   gem install mysql"


docker commit my-ruby my-jekyll-importer-image

docker run \
--link some-mysql:mysql \
my-jekyll-importer-image \
ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal7.run({
      "dbname"   => "drupal",
      "user"     => "root",
      "password" => "rootpassword",
      "host"     => "mysql",
      "prefix"   => "",
      "types"    => ["blog", "story", "article"]
    })'








docker run --name my-importer ruby


      ; USE drupal2; source data.sql"

mysql> USE mydb;

mysql> source bkp3.sql"
    # Import our database
    cat ~/Desktop/my-drupal-7-database.sql | docker run \
      --link some-mysql:mysql \
      --rm \
      mysql \
      mysql -hmysql -uroot -prootpassword drupal



https://github.com/jekyll/jekyll-redirect-from


I found the [Drupal Jekyll Export](https://github.com/lukaswhite/Drupal-Jekyll-Export) module on GitHub which does exactly that.

I have


devseed
is this a threat?
clients
considerably less cost
