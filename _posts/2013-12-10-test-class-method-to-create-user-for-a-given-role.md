---
layout: post
title: Test class method to create user for a given role
id: 45
created: 1386714162
tags:
  - snippet
permalink: /blog/45/test-class-method-create-user-given-role/
redirect_from:
  - /blog/45/
  - /node/45/
---
    /**
     * Create a user with specific roles
     *
     * See http://blog.dcycle.com/blog/45
     *
     * @param $roles
     *   An array of roles by human name, for example, array('administrator', etc.)
     * @param
     *   A Drupal user object.
     *
     * @throws
     *   Exception if undefined roles
     */
    public function createUserWithRoles($roles) {
      $user = $this->drupalCreateUser();
      foreach ($roles as $role_name) {
        $role = user_role_load_by_name($role_name);
        if (!$role) {
          throw new Exception('Role ' . $role_name . ' does not seem to be valid; available roles are ' . serialize(user_roles()));
        }
        $user->roles[$role->rid] = $role_name;
      }
      user_save($user);
      return $user;
    }
