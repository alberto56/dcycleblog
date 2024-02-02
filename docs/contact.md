---
layout: default
title: Contact Dcycle
---

<div id="contact">
  <h1 class="pageTitle">Contact</h1>
  <div class="contactContent">
    <p class="intro">This blog is maintained by Albert Albala, Montreal-based Drupal developer specializing in automated tests and continuous integration.</p>
    <ul>
      <li><a href="http://albertalbala.com/en.html">More about me.</a></li>
      <li>Use the contact form if you'd like some freelance consulting.</li>
      <li><a href="https://www.linkedin.com/in/albertalbala">Follow me on Linkedin.</a></li>
      <li><a href="https://www.drupal.org/u/alberto56">My Drupal.org profile.</a></li>
      <li><a href="https://github.com/alberto56">My Github profile.</a></li>
      <li><a href="https://twitter.com/alberto56">Follow me on Twitter.</a></li>
    </ul>
  </div>
  <form action="https://formspree.io/albert@dcycle.com" method="POST">
    <label for="name" required>Name</label>    
    <input type="hidden" name="_next" value="http://blog.dcycle.com/thanks">
    <input type="text" id="name" name="name" class="full-width"><br>
    <label for="_replyto">Email Address</label>
    <input type="text" name="_gotcha" style="display:none" />
    <input type="email" id="email" name="_replyto" class="full-width" required><br>
    <label for="message">Message</label>
    <textarea name="message" id="message" cols="30" rows="10" class="full-width" required></textarea><br>
    <input type="submit" value="Send" class="button">
  </form>
</div>
