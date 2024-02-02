---
layout: post
title: Installing an evaluation version of Phabricator
author: admin
id: 79
created: 1417541158
tags:
  - blog
permalink: /blog/79/installing-evaluation-version-phabricator/
redirect_from:
  - /blog/79/
  - /node/79/
---
[Phabricator](http://phabricator.org) is a free open-source code review and workflow management system. Here is how to quickly install Phabricator in a manner which should be considered non-secure, so you can determine if it is right for you. You might also be interested in [Gerrit](http://blog.dcycle.com/blog/82/setting-gerrit-centos-evaluation) or [Gitlab](https://about.gitlab.com), similar products.

(Fans of Docker can skip this entire procedure and [use this Docker image](https://github.com/yesnault/docker-phabricator) instead.)

Step 1: get a new server
------------------------

I do not recommend installing this on an existing server or alongside other software. Start with a new CentOS 6.x server with 1 Gb of RAM (I used [Digital Ocean](https://www.digitalocean.com/)). Note your server IP address (1.2.3.4)

Step 2: set up a subdomain to point to your server
--------------------------------------------------

Using your domain management system (I use [AlternC](http://alternc.org) hosted at [Koumbit](https://www.koumbit.org)), create a new subdomain (phabricator.example.com) which points to 1.2.3.4.

Step 3: install LAMP and make sure everything works
---------------------------------------------------

Create a user "demo" with sudo privileges and install LAMP as per [these instructions](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-centos-6), making sure you take note of the root mysql password in the process.

Then, install the mbstring extension

		sudo yum install php-mbstring
		sudo apachectl restart

Finally, make sure everything works:

 * Visit http://phabricator.example.com and it should show you the Apache welcome page.
 * Visit http://1.2.3.4 and it should show you the Apache welcome page.

Step 4: download Phabricator
----------------------------

    sudo su demo
    cd
    sudo yum install git
    git clone https://github.com/phacility/libphutil.git
    git clone https://github.com/phacility/arcanist.git
    git clone https://github.com/phacility/phabricator.git

Typing:

    /home/demo/phabricator/webroot/

Should give the result

    bash: /home/demo/phabricator/webroot/: is a directory

Step 5: Set up Virtual Hosts to access Phabricator
--------------------------------------------------

For this we will be using virtual hosts.  Edit the conf file by typing

    sudo vi /etc/httpd/conf/httpd.conf

Make the following changes/additions to `/etc/httpd/conf/httpd.conf`:

### run as demo user

Find the line which starts with "User" and make

    User demo
    Group demo

### Add a VirtualHost section to the end of your httpd.conf document:

    <VirtualHost *>
      # Change this to the domain which points to your host.
      ServerName phabricator.example.com

      # Change this to the path where you put 'phabricator' when you checked it
      # out from GitHub when following the Installation Guide.
      #
      # Make sure you include "/webroot" at the end!
      DocumentRoot /home/demo/phabricator/webroot

      RewriteEngine on
      RewriteRule ^/rsrc/(.*)     -                       [L,QSA]
      RewriteRule ^/favicon.ico   -                       [L,QSA]
      RewriteRule ^(.*)$          /index.php?__path__=$1  [B,L,QSA]
    </VirtualHost>
    <Directory "/home/demo/phabricator/webroot">
      Order allow,deny
      Allow from all
    </Directory>

### Restart Apache

    sudo apachectl restart

### Debug

Make sure the page http://phabricator.example.com gives you the Phabricator setup page. If you are getting a "Permission denied" or "Internal server error" problem, it is probably a server config problem; make sure you following all the instructions above very carefully and leave a comment if you find there was something missing.

Step 6: Install (setup) Phabricator
-----------------------------------

Visit phabricator.example.com and follow the instructions on-screen. You might have missing php extensions and you will need to set the mysql credentials on the command line.

Reload the page after each action you perform on the command line. If you get an "Authentication problem" message, just reload the page. Eventually you will get a page with:

    "Installation is complete. Register your administrator account..."

Create the admin user account.

Congratulations
---------------

You now have an insecure version of Phabricator for evaluation and demo purposes! I'll give some indications on how to use it in a following post.

Next step
----------

 * [Setting up a link between Phabricator and a git repo](http://blog.dcycle.com/blog/80/setting-phabricator-track-git-repo)
