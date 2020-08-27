---
layout: post
title: Solving The document could not be autosaved. The file name is invalid. on macOS
id: 2f690fca
tags:
  - snippet
permalink: /blog/2f690fca/could-not-save/
redirect_from:
  - /blog/2f690fca/
  - /node/2f690fca/
---
I have the latest version of OmniOutliner and macOS 10.15.6.

I have been using a file called daily3.oo3 (an OmniOutliner file) for several years to track my daily to-do list with no issues. This morning the file has started to refuse to save, giving me the message:

"The document could not be autosaved. The file name is invalid."

I restarted my computer, resaved the file elsewhere, even used Disk First Aid to fix my entire disk, but nothing worked.

This is a follow-up to the post 'Error: "The document could not be autosaved. The file name is invalid."', Posted on Mar 19, 2014 8:39 AM, at https://discussions.apple.com/thread/6011576.

Here is the solution I found. The daily3.oo3 file is actually a folder, and that folder contains images which were added to the daily3.oo3 file, including Screenshots such as Screen_Shot_2020-01-10_at_1.22.07_PM, etc.

However, there seems to have been a glitch whereby some files were renamed in such a way that the included screenshots have invalid names.

    $ cd /Users/albert/Documents/backup/critical2/daily3.oo3
    $ ls
    total 2328
    drwxr-xr-x@ 7 albert  staff   224B 27 Aug 12:18 .
    drwxr-xr-x+ 4 albert  staff   128B 27 Aug 12:20 ..
    -rw-r--r--@ 1 albert  staff    41K 21 Oct  2019 Screen_Shot_2019-10-21_at_11.51.52_AM.png_1_1.jpg
    -rw-r--r--@ 1 albert  staff    94K 10 Jan  2020 Screen_Shot_2020-01-10_at_1.22.07_PM_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1.png
    -rw-r--r--@ 1 albert  staff   356K  8 May 15:18 Screen_Shot_2020-05-08_at_3.18.22_PM_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_2_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1.png
    -rw-r--r--@ 1 albert  staff   405K 25 Jun 22:24 Screen_Shot_2020-06-25_at_10.24.35_PM_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1.png
    -rw-r--r--@ 1 albert  staff   257K 27 Aug 12:18 contents.xml

I have no idea why the screenshots were renamed this way. I simply quit OmniOutliner, backed up and then removed those screenshot files, then reopened the file and all was good (except the screenshots which no longer are present).
The document could not be autosaved. The file name is invalid. With possible solution.
