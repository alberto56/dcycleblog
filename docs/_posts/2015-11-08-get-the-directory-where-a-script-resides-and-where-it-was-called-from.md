---
layout: post
title: Get the directory where a script resides and where it was called from
author: admin
id: 104
created: 1446948223
tags:
  - snippet
permalink: /blog/104/get-directory-where-script-resides-and-where-it-was-called/
redirect_from:
  - /blog/104/
  - /node/104/
---
    SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
    echo $SCRIPTDIR
    CALLDIR="$(pwd -P)"
    echo $CALLDIR
