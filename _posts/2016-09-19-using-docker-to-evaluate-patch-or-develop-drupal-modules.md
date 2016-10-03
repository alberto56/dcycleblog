---
layout: post
title: Using Docker to evaluate, patch or develop Drupal modules
author: admin
id: 113
created: 1474296697
tags:
  - blog
  - planet
permalink: /blog/113/using-docker-evaluate-patch-or-develop-drupal-modules/
redirect_from:
  - /blog/113/
  - /node/113/
---

[Docker](https://www.docker.com) is now available [natively on Mac OS](https://docs.docker.com/docker-for-mac/) in addition to Linux. Docker is also included with [CoreOS](https://coreos.com) which you can run on remote Virtual Machines, or locally through [Vagrant](https://coreos.com/os/docs/latest/booting-on-vagrant.html).

Once you have installed Docker and Git, locally or remotely, you don't need to install anything else.

In these examples we will leverage the official [Drupal](https://hub.docker.com/_/drupal/) and [mySQL](https://hub.docker.com/_/mysql/) Docker images. We will use the mySQL image as is, and we will add [Drush](https://github.com/drush-ops/drush) to our Drupal image.

Docker is efficient with caching: these scripts will be slow the first time you run them, but very fast thereafter.

Here are a few scripts I often use to set up quick Drupal 7 or 8 environments for module evaluation and development.

Keep in mind that using Docker for deployment to production is another topic entirely and is not covered here; also, these scripts are meant to be _quick and dirty_; `docker-compose` might be useful for more advanced usage.

Port mapping
-----

In all cases, using `-p 80`, I map port 80 of Drupal to any port that happens to be available on my host, and in these examples I am using Docker for Mac OS, so my sites are available on `localhost`.

I use `DRUPALPORT=$(docker ps|grep drupal7-container|sed 's/.*0.0.0.0://g'|sed 's/->.*//g')` to figure out the current port of my running containers. When your containers are running, you can also just `docker ps` to see port mapping:

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
    f1bf6e7e51c9        drupal8-image       "apache2-foreground"     15 seconds ago      Up 11 seconds       0.0.0.0:32771->80/tcp   drupal8-container
    ...

In the above example (scroll right to see more outpu), port `http://localhost:32771` will show your Drupal 8 site.

Using Docker to evaluate, patch or develop Drupal 7 modules
-----

I can set up a quick environment to evaluate one or more Drupal 7 modules. In this example I'll evaluate Views.

    mkdir ~/drupal7-modules-to-evaluate
    cd ~/drupal7-modules-to-evaluate
    git clone --branch 7.x-3.x https://git.drupal.org/project/views.git
    # add any other modules for evaluation here.

    echo 'FROM drupal:7' > Dockerfile
    echo 'RUN curl -sS https://getcomposer.org/installer | php' >> Dockerfile
    echo 'RUN mv composer.phar /usr/local/bin/composer' >> Dockerfile
    echo 'RUN composer global require drush/drush:8' >> Dockerfile
    echo 'RUN ln -s /root/.composer/vendor/drush/drush/drush /bin/drush' >> Dockerfile
    echo 'RUN apt-get update && apt-get upgrade -y' >> Dockerfile
    echo 'RUN apt-get install -y mysql-client' >> Dockerfile
    echo 'EXPOSE 80' >> Dockerfile

    docker build -t drupal7-image .
    docker run --name d7-mysql-container -e MYSQL_ROOT_PASSWORD=root -d mysql
    docker run -v $(pwd):/var/www/html/sites/all/modules --name drupal7-container -p 80 --link d7-mysql-container:mysql -d drupal-image

    DRUPALPORT=$(docker ps|grep drupal7-container|sed 's/.*0.0.0.0://g'|sed 's/->.*//g')

    # wait for mysql to fire up. There's probably a better way of doing this...
    # See stackoverflow.com/questions/21183088
    # See https://github.com/docker/compose/issues/374
    sleep 15

    docker exec drupal7-container /bin/bash -c "echo 'create database drupal'|mysql -uroot -proot -hmysql"
    docker exec drupal7-container /bin/bash -c "cd /var/www/html && drush si -y --db-url=mysql://root:root@mysql/drupal"
    docker exec drupal7-container /bin/bash -c "cd /var/www/html && drush en views_ui -y"
    # enable any other modules here. Dependencies will be downloaded
    # automatically

    echo -e "Your site is ready, you can log in with the link below"

    docker exec drupal7-container /bin/bash -c "cd /var/www/html && drush uli -l http://localhost:$DRUPALPORT"

Note that we are _linking_ (rather than _adding_) `sites/all/modules` as a volume, so any change we make to our local copy of views will quasi-immediately be reflected on the container, making this a good technique to develop modules or write patches to existing modules.

When you are finished you can destroy your containers, noting that all data will be lost:

    docker kill drupal7-container d7-mysql-container
    docker rm drupal7-container d7-mysql-container

Using Docker to evaluate, patch or develop Drupal 8 modules
-----

Our script for Drupal 8 modules is slightly different:

 * `./modules` is used on the container instead of `./sites/all/modules`;
 * Our `Dockerfile` is based on `drupal:8`, not `drupal:7`;
 * Unlike with Drupal 7, your database is not required to exist prior to installing Drupal with Drush;
 * In my tests I need to `chown /var/www/html/sites/default/files` to `www-data:www-data` to enable Drupal to write files.

Here is an example where we are evaluating the [Token](https://www.drupal.org/project/token) module for Drupal 8:

    mkdir ~/drupal8-modules-to-evaluate
    cd ~/drupal8-modules-to-evaluate
    git clone --branch 8.x-1.x https://git.drupal.org/project/token.git
    # add any other modules for evaluation here.

    echo 'FROM drupal:8' > Dockerfile
    echo 'RUN curl -sS https://getcomposer.org/installer | php' >> Dockerfile
    echo 'RUN mv composer.phar /usr/local/bin/composer' >> Dockerfile
    echo 'RUN composer global require drush/drush:8' >> Dockerfile
    echo 'RUN ln -s /root/.composer/vendor/drush/drush/drush /bin/drush' >> Dockerfile
    echo 'RUN apt-get update && apt-get upgrade -y' >> Dockerfile
    echo 'RUN apt-get install -y mysql-client' >> Dockerfile
    echo 'EXPOSE 80' >> Dockerfile

    docker build -t drupal8-image .
    docker run --name d8-mysql-container -e MYSQL_ROOT_PASSWORD=root -d mysql
    docker run -v $(pwd):/var/www/html/modules --name drupal8-container -p 80 --link d8-mysql-container:mysql -d drupal8-image

    DRUPALPORT=$(docker ps|grep drupal8-container|sed 's/.*0.0.0.0://g'|sed 's/->.*//g')

    # wait for mysql to fire up. There's probably a better way of doing this...
    # See stackoverflow.com/questions/21183088
    # See https://github.com/docker/compose/issues/374
    sleep 15

    docker exec drupal8-container /bin/bash -c "cd /var/www/html && drush si -y --db-url=mysql://root:root@mysql/drupal"
    docker exec drupal8-container /bin/bash -c "chown -R www-data:www-data /var/www/html/sites/default/files"
    docker exec drupal8-container /bin/bash -c "cd /var/www/html && drush en token -y"
    # enable any other modules here.

    echo -e "Your site is ready, you can log in with the link below"

    docker exec drupal8-container /bin/bash -c "cd /var/www/html && drush uli -l http://localhost:$DRUPALPORT"

Again, when you are finished you can destroy your containers, noting that all data will be lost:

    docker kill drupal8-container d8-mysql-container
    docker rm drupal8-container d8-mysql-container
