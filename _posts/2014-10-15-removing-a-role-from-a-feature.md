---
layout: post
title: Removing a role from a feature
author: admin
id: 76
created: 1413378509
tags:
  - snippet
permalink: /blog/76/removing-role-feature/
redirect_from:
  - /blog/76/
  - /node/76/
---
Say you have created a user role and deployed it with a feature dependent on your [site deployment module](http://dcycleproject.org/blog/44/what-site-deployment-module). Now you want to delete it:

First, remove it from your feature.

Next, add an update hook to your site deployment module reverting your feature.

You will still need to remove it by adding this code to an update hook in your site deployment module.

    $r = user_role_load_by_name('role name');
    if ($r) {
      user_role_delete('role name');
    }
