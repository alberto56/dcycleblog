---
layout: post
title: Get the latest NID in the system
id: 64
created: 1401889695
tags:
  - snippet
permalink: /blog/64/get-latest-nid-system/
redirect_from:
  - /blog/64/
  - /node/64/
---
During tests, I often find myself in need of the latest nid that was created. Here is how to do it:

    return db_query_range("SELECT nid FROM {node} ORDER BY nid DESC", 0, 1)->fetchField();

This will print the nid (3, for example).
