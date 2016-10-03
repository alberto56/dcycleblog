---
layout: post
title: Printing a structured variable during a simpletest
id: 49
created: 1389995179
tags:
  - snippet
permalink: /blog/49/printing-structured-variable-during-simpletest/
redirect_from:
  - /blog/49/
  - /node/49/
---
When debugging a simpletest, you might need to inspect a structured variable. I find the easiest way is to print it to Simpletest's log, like this:

    $this->error('<pre>' . print_r($this->$log->getErrors(), TRUE) . '</pre>', 'User notice');

The method name is a bit misleading here: we are not printing an error, but rather logging a user notice.
