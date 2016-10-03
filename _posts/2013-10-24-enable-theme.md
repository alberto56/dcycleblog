---
layout: post
title: Enable theme
id: 31
created: 1382646771
tags:
  - snippet
permalink: /blog/enable-theme/
redirect_from:
  - /blog/31/
  - /node/31/
---
    <?php
    theme_enable(array('mytheme'));
    variable_set('theme_default', 'mytheme');

and for the test

    <?php
    $this->drupalGet('/');
    $this->assertRaw('themes/mytheme');
