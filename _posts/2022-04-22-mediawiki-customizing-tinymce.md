---
layout: post
title:  "Customizing TinyMCE on Mediawiki"
author: admin
id: 2022-04-22
tags:
  - blog
permalink: /blog/2022-04-22/mediawiki-customizing-tinymce/
redirect_from:
  - /blog/2022-04-22/
  - /node/2022-04-22/
---

In this post we will look at how to customize the TinyMCE toolbar for Mediawiki, by making custom toolsets, and we will look at the challenge of figuring out machine names of tools you would like to use.

To follow along, if you have Docker installed, you can use the [Dcycle Mediawiki Starterkit](https://github.com/dcycle/starterkit-mediawiki). You can also fork the project if you want to use it as a basis for your own project.

Download that project and run:

    ./scripts/deploy.sh

That should give you a local URL and username and password to log into an empty wiki.

For now there is no Wysiwyg at all.

Once logged in, go to http://0.0.0.0:8080/index.php/Some_new_page and click "Create this page". Enter "Hello World" and click Save.

Installing the TinyMCE wysiwyg editor
-----

Let's start by installing TinyMCE with its default configuration. This requires a few steps:

* Downloading the TinyMCE code
* Installing TinyMCE in Mediawiki's configuration
* Rebuild and restart the containers

Dcycle Mediawiki Starterkit has commented-out code in [./docker-resources/load-extensions.sh](https://github.com/dcycle/starterkit-mediawiki/blob/master/docker-resources/load-extensions.sh) and [./docker-resources/load-extensions.php](https://github.com/dcycle/starterkit-mediawiki/blob/master/docker-resources/load-extensions.php) to help you. Uncomment that code in your installation, and restart the containers by running, once again:

    ./scripts/deploy.sh

Now you can go back to http://0.0.0.0:8080/index.php/Some_new_page, click "Edit", and you will see a working instance of TinyMCE.

Customizing TinyMCE toolbar
-----

The toolbar can be configured in ./docker-resources/load-extensions.php

Let's start by adding the following code to make a very minimalist version of the Wysiwyg with only "undo", "redo", and, in a separate section (the section change is denoted by the "pipe" character or "\|"), "table":

    $wgTinyMCESettings = [
      "#wpTextbox1" => [
        "toolbar" => implode(' ', [
          'undo',
          'redo',
          '|',
          'table',
        ]),
      ],
    ];

Once again, run:

    ./scripts/deploy.sh

Once again, go back to http://0.0.0.0:8080/index.php/Some_new_page, click "Edit", and you will see your new minimalist toolbar.

Toolbar icon machine names
-----

Now the question is, how do we know that if we want the "Table" icon, its machine name is "table" (as opposed to, say, "wikitable" or something else)?

It turns out that there does not seem to be a centralized list of machine names-to-icons; and finding out the machine name to use for your desired result requires a combination of internet sleuthing and a deep-dive into the source code of [the TinyMCE page](https://www.mediawiki.org/wiki/Extension:TinyMCE).

For example, on the Mediawiki page [Customize toolbar icons, Mediawiki.org, last updated April 21, 2021](https://www.mediawiki.org/wiki/Topic:W76akrulq9pkf5te), we see a list of machine names for icons:

> undo redo | cut copy paste insert selectall | fontselect fontsizeselect bold italic underline strikethrough subscript superscript forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist advlist outdent indent | wikilink wikiunlink table image media | formatselect removeformat| visualchars visualblocks| searchreplace | wikimagic wikisourcecode wikitext wikiupload | wikitoggle nonbreaking singlelinebreak reference comment template

That's all fine and good, but what if the tool you are looking for is not there? For example, on [the TinyMCE page](https://www.mediawiki.org/wiki/Extension:TinyMCE), it says, at the time of this writing, that there is a tool allowing entering a citation or footnote with this icon:

<img src="https://upload.wikimedia.org/wikipedia/commons/d/de/Reference_button_capture_from_TinyMCE_extension.png" alt="icon ab[1] for a footnote" />

> will insert a citation or reference into the content at the cursor position. If anything is selected when the button is pressed it will form the content of the reference.  The reference is initially displayed as [[n]] in the editor.  

**But after a long search I could not find any machine name that works for this**.

I opened a [Stackoverflow question: In Mediawiki's tinymce extension, how to enable/disable buttons?](https://stackoverflow.com/questions/71577367/in-mediawikis-tinymce-extension-how-to-enable-disable-buttons), which touches on this. Unfortunately it did not go viral...

I have had to do quite a bit of forensic searching [in the source code](https://github.com/wikimedia/mediawiki-extensions-TinyMCE) to obtain a lot of leads that did not work, like [footnote](https://github.com/wikimedia/mediawiki-extensions-TinyMCE/search?q=footnote), [reference](https://github.com/wikimedia/mediawiki-extensions-TinyMCE/search?q=editor.ui.registry.addMenuItem&type=code), [mw_wikireference](https://github.com/wikimedia/mediawiki-extensions-TinyMCE/search?q=mw_wikireference&type=code).

So what is the machine name for the citation/reference tool? This is one of those cases where I came up empty-handed. If you know what it is, please provide the answer in the comments or on the Stackoverflow question mentioned above.
