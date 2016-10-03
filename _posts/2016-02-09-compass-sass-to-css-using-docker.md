---
layout: post
title: Compass Sass to CSS using Docker
author: admin
id: 107
created: 1455036703
tags:
  - blog
permalink: /blog/107/compass-sass-css-using-docker/
redirect_from:
  - /blog/107/
  - /node/107/
---
I have seen many developers on a few teams cringe when they need to make a simple CSS change and are faced with this folder structure:

    myproject
      some-folder
        another-folder
          sass
            something.scss
          css
            something.css

In my opinion `myproject/some-folder/another-folder/css/*` should not be in version control in the first place, but it often is. In my case, I know almost nothing about sass, and I surely do not want to install sass precompilers on my local development machine.

If you have access to Docker, either on your machine on a CoreOS virtual machine, I found a nifty Docker image which does a good job: [antonienko/compass-watch](https://hub.docker.com/r/antonienko/compass-watch/).

Here is how to use it:

First, make sure you have a file called `myproject/some-folder/another-folder/config.rb` which contains the following:

    css_dir = "css" # where the CSS will saved
    sass_dir = "sass" # where our .scss files are
    images_dir = "css/img" # or whatever

    # You can select your preferred output style here (can be overridden via the command line):
    output_style = :expanded # After dev :compressed

    # To disable debugging comments that display the original location of your selectors. Uncomment:
    line_comments = true

    # Obviously
    preferred_syntax = :scss

Then run this docker command every time you want to recompile your .scss file.

    docker run -v $(pwd):/src antonienko/compass-watch compile /src/some-folder/another-folder --force

This will generate css based on the current scss, then destroy the Docker container.

Note that the project page for [antonienko/compass-watch](https://hub.docker.com/r/antonienko/compass-watch/) provides instructions on how to _watch_ a scss folder to continually create css. This was not working for me, and I prefer to regenerate my css every time I need it.
