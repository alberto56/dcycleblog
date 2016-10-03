---
layout: post
title: Search and replace on the command line
author: admin
id: 106
created: 1450450271
tags:
  - snippet
permalink: /blog/106/search-and-replace-command-line/
redirect_from:
  - /blog/106/
  - /node/106/
---
    echo "THIS IS A STRING TO REPLACE" >> file.txt
    sed -i.bak "s/STRING TO REPLACE/REPLACED STRING/g" file.txt
    rm file.txt.bak
    cat file.txt
    # THIS IS A REPLACED STRING
