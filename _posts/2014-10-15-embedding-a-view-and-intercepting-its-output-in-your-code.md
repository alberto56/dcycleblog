---
layout: post
title: Embedding a view and intercepting its output in your code
author: admin
id: 77
created: 1413384346
tags:
  - snippet
permalink: /blog/77/embedding-view-and-intercepting-its-output-your-code/
redirect_from:
  - /blog/77/
  - /node/77/
---
    $view = views_get_view('my_view_machine_name');
    $view->set_display('block');
    $view->set_arguments(array($arg1, $arg2));
    // change the amount of items to show
    $view->pre_execute();
    $view->execute();
    // you can change $view->result here if you want. Use the
    // devel module and dpm($view->result) to inspect what
    // it looks like.
    return $view->render();
