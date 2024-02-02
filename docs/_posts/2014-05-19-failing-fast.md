---
layout: post
title: Failing fast
id: 61
created: 1400504659
tags:
  - snippet
permalink: /blog/61/failing-fast/
redirect_from:
  - /blog/61/
  - /node/61/
---
Normally, all failures are logged, but tests continue. If you project contains an hour's worth of tests which are run on every commit by a continuous integration server, you might elect to fail fast: if something goes wrong, don't continue testing. To do this you might add this code to your base project's base test, it will raise an exception in case of a failure, stopping the testing process with a failure.

    protected function assert($status, $message = '', $group = 'Other', array $caller = NULL) {
      $return = parent::assert($status, $message, $group, $caller);
      if (!$return && (!$status || $status == 'fail')) {
        // fail fast
        throw new Exception('Failing fast: ' . $message);
      }
      return $return;
    }
