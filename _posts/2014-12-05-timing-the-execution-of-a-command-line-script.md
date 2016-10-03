---
layout: post
title: Timing the execution of a command-line script
author: admin
id: 86
created: 1417789636
tags:
  - snippet
permalink: /blog/86/timing-execution-command-line-script/
redirect_from:
  - /blog/86/
  - /node/86/
---
I often find myself wanting to know how long something takes on the command line, here is one way of doing it:

    START=$(date +%s)
    # do somehing
    echo "Completed in $(echo $(date +%s)-$START|bc) seconds"

In some cases the `bc` command is unavailable. For example, CoreOS does not ship with `bc`. The following is better suited to those situations:

    START=$(date +%s)
    # do something
    SECONDS=`expr $(date +%s) - $START`
    echo "Completed in $SECONDS seconds"
