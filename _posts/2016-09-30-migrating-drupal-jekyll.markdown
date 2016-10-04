---
layout: post
title:  "Migrating data from Drupal to Jekyll"
date:   2016-09-30
tags:
  - blog
id: 2016-09-30
permalink: /blog/2016-09-30/migrating-drupal-jekyll/
redirect_from:
  - /blog/2016-09-30/
---

This technical post will run through how I went about migrating this site (the Dcycle blog) from Drupal to Jekyll. For the reasons _why_ I migrated, please see [Know when not to use Drupal](http://dcycleproject.org/blog/2016-10-02).

Exporting very simple content from Drupal to Jekyll
-----

Depending on the complexity of your content, mapping your content will likely be the longest part of your migration, and will necessitate some trial and error, and perhaps some manual intervention.

Jekyll underlying content is just straight-up files written in Markdown, with links to some images. Every time the underlying content changes, Jekyll will generate your entire site as static html in a `_site` subfolder.

Jekyll provides [_importers_ to "Import your old & busted site or blog for use with Jekyll."](http://import.jekyllrb.com), but as you will see they are very basic; fields, tags, path aliases and images are not imported. I decided to add my extra information manually (which took me about two hours) because I only had about a hundred posts. If you want to further automate things, you might want to try the [Jekyll RSS importer](http://import.jekyllrb.com/docs/rss/) instead of the Drupal importer, and build an RSS feed on your Drupal site (using [Views RSS](https://www.drupal.org/project/views_rss), for example), if you want greater control of what is imported into Drupal.

There are importers for Drupal 6 and 7 at the time of this writing. Here is how I used the Drupal 7 importer using Docker (you don't need to install anything on your system except Docker to run these commands):

_First_, make sure you have a dump of your Drupal 7 database; assuming your database is MySQL, if you have ssh access to the server where your Drupal site is located, and `drush` is installed on that server, you can get the database dump by running something like:

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

_Third_, create a working directory with a Dockerfile containing the `jekyll-import` gem and some dependencies.

    mkdir ~/Desktop/my-importer
    cd ~/Desktop/my-importer
    echo 'FROM ruby' >> Dockerfile
    echo 'RUN gem install jekyll-import' >> Dockerfile
    echo 'RUN gem install sequel' >> Dockerfile
    echo 'RUN gem install mysql' >> Dockerfile

_Next_, build the image, and run a container linked to your mysql container, then import everything:

    docker build -t my-importer-image .

    docker run \
      --name my-importer-container \
      --link some-mysql:mysql \
      my-importer-image \
      ruby -rubygems -e 'require "jekyll-import";
          JekyllImport::Importers::Drupal7.run({
            "dbname"   => "drupal",
            "user"     => "root",
            "password" => "rootpassword",
            "host"     => "mysql",
            "prefix"   => "",
            "types"    => ["blog", "story", "article"]
          })'

    docker commit my-importer-container my-importer-image

    id=$(docker create my-importer-image)
    docker cp $id:\_drafts .
    docker cp $id:\_posts .
    docker rm -v $id

You will now have your posts in the `~/Desktop/my-importer/_posts` and `~/Desktop/my-importer/_drafts` folder; however information other than body and title will not appear. Specifically, images, tags, path aliases will be missing. Once you add these manually, your content migration will be done.

Exporting comments to Disqus
-----

Because Jekyll is static HTML, user comments need a place to be stored. I chose [Disqus](https://disqus.com) which seems to be an emerging standard. To export your comments from your Drupal site to Disqus, you can use the [Disqus Migrate](https://www.drupal.org/project/disqus_migrate) module which does a good job creating an XML file of all your comments. Each thread is identified by a thread URL (link) and thread ID. I needed to tweak mine by adding a trailing slash to the link, and changing the basic identifier from `node/x` to the canonical URL, for example:

    ...
    <link>http://blog.dcycle.com/blog/48/do-not-clone-database/</link>
    <content:encoded></content:encoded>
    <dsq:thread_identifier>/blog/48/do-not-clone-database/</dsq:thread_identifier>
    ...

Once tweaked, you can import your comments into your Disqus administrative interface.

Then, in your Jekyll post template, you will add the [Disqus embed code](https://help.disqus.com/customer/portal/articles/472097-universal-embed-code), and specify the link and identifier like this:

    ...
    <div id="disqus_thread"></div>
    <script>
        var disqus_config = function () {
            this.page.url = "http://mysite.example.com{{% comment %}{% endcomment %}{ page.url }{% comment %}{% endcomment %}}";
            this.page.identifier = "{{% comment %}{% endcomment %}{ page.url }{% comment %}{% endcomment %}}";
        };
    ...


