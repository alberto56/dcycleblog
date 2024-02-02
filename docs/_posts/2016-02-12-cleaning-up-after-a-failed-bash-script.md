---
layout: post
title: Cleaning up after a failed bash script
author: admin
id: 108
created: 1455314411
tags:
  - snippet
permalink: /blog/108/cleaning-after-failed-bash-script/
redirect_from:
  - /blog/108/
  - /node/108/
---
If your bash script is called test.sh, and you need to clean up temporary files regardless of the exit code, you could do something like this:

    #!/bin/bash
    # test.sh
    # pass all arguments to the main script
    ./test-main.sh "$@"
    EXITCODE=$?
    echo 'cleanup'
    if [[ $EXITCODE -eq 1 ]]; then
      echo 'about to exit with 1'
      exit 1;
    else
      echo 'about to exit with 0'
      exit 0;
    fi

And then put your logic in test-main.sh, like this:

    #!/bin/bash
    # test-main.sh
    # set -e propagates errors and terminates the script
    set -e
    # do your stuff
