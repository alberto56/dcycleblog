---
layout: post
title: In tests, finding patterns in mail messages
author: admin
id: 72
created: 1410886916
tags:
  - snippet
permalink: /blog/72/tests-finding-patterns-mail-messages/
redirect_from:
  - /blog/72/
  - /node/72/
---
Add this to your test class, and you can then find grep patterns in the latest email sent

    /**
     * We are expecting a mail to have been created, and to contain a pattern
     */
    public function findInMail($grep, $mail_index = -1) {
      $mails = $this->drupalGetMails();
      if ($mail_index == -1) {
        $last_mail = end($mails);
      }
      elseif ($mail_index < 0) {
        $index = count($mails) + $mail_index;
        $this->assertTrue($index >= 0, 'We are looking for an email with a valid index (' . $index . ')');
        if (!isset($mails[$index])) {
          $this->assertTrue(FALSE, 'There are ' . count($mails) . ' in total but we are trying to look in mail # ' . $index);
        }
        $last_mail = $mails[$index];
      }
      else {
        $last_mail = $mails[$mail_index];
      }
      if (!$last_mail) {
        $this->assertTrue(FALSE, 'There are no mails to look in');
        return;
      }
      if (!isset($last_mail['body'])) {
        $this->assertTrue(FALSE, 'A mail has been sent by the system but does not contain a body element');
        $this->inspect($last_mail);
        return;
      }
      $body = $last_mail['body'];
      if (!drupal_strlen($body)) {
        $this->assertTrue(FALSE, 'A mail has been sent by the system, it contains a body element, but not text');
        $this->inspect($last_mail);
        return;
      }
      $matches = array();
      $result = $this->pregMatch($grep, $body, $matches, TRUE);
      if (isset($matches[1])) {
        $this->assertTrue(isset($matches[1]), 'We found ' . $grep . ': ' . $matches[1] . ': ' . $result);
        return $matches[1];
      }
      $this->assertTrue(isset($matches[0]), 'We found ' . $grep . ': ' . $matches[0] . ': ' . $result);
      return $matches[0];
    }

    public function pregMatch($grep, $body, &$matches = array(), $expecting = FALSE) {
      // see http://stackoverflow.com/questions/3710454
      $old_error = error_reporting(0); // Turn off error reporting

      $result = preg_match($grep, $body, $matches);
      if ($result === 0 && $expecting) {
        $this->inspect($body);
        $this->assertTrue(FALSE, 'We were expecting to find the pattern ' . htmlentities($grep) . ' but it is not there. Inspecting the haystack (which has a length of ' . drupal_strlen($body) . ') in the preceding line.');
      }
      else {
        $this->assertTrue(TRUE, 'As expected, we found the  pattern ' . $grep . '.. Inspecting the haystack (which has a length of ' . drupal_strlen($body) . ') in the following line.');
        $this->inspect($body);
      }
      if ($result === FALSE) {
        $this->assertTrue(FALSE, 'An error occurred searching for the pattern ' . $grep . ': ' . $error["message"] . '. Inspecting the body in the following line');
        $this->inspect($body);
      }
      error_reporting($old_error);  // Set error reporting to old level

      return $result;
    }

    /**
     * Inspect a structured data on the test page.
     *
     * Useful for debugging.
     */
    public function inspect($x) {
      try {
        $this->verbose('<pre>' . print_r($x, TRUE) . '</pre>');
      }
      catch(Exception $e) {
        $this->assertTrue(FALSE, 'Error ' . $e->getMessage() . '  while trying to display : ' . serialize($x));
      }
    }
