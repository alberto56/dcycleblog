---
layout: post
title: systemd as a replacement for cron every 10 seconds
author: admin
id: 112
created: 1468424664
tags:
  - snippet
permalink: /blog/112/systemd-replacement-cron-every-10-seconds/
redirect_from:
  - /blog/112/
  - /node/112/
---
I use [CoreOS](https://coreos.com) which does not support cron, and uses `systemd` instead. I sometimes need to run scripts every set time, for example every 10 seconds; here is how I go about it:

First, [Scheduling tasks with systemd timers](https://coreos.com/os/docs/latest/scheduling-tasks-with-systemd-timers.html) on the CoreOS website contains the basics, but the task is set to run every 10 minutes:

    OnCalendar=*:0/10

I have found very little information online about the `OnCalendar` syntax, but by trial and error, I have gotten my scripts to work every 10 seconds like this:

    OnCalendar=*:*:0/10
