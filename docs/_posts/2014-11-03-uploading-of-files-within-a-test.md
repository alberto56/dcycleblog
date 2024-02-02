---
layout: post
title: Uploading of files within a test
author: admin
id: 78
created: 1415052209
tags:
  - snippet
permalink: /blog/78/uploading-files-within-test/
redirect_from:
  - /blog/78/
  - /node/78/
---
Testing uploading of files within a test:

If you need to test file upload functionality in a test, you might be tempted to use something like:

    ...
    $edit = array(
    	...
    	['myfield'] =>  'sites/all/modules/mymodule/test-files/my-test-file.png',
    	...
    );
		$this->drupalPost('my/module/path', $edit, 'Save');
		...

This will work in some dev environments but, on others, will cause a "this file cannot be uploaded" error. The reason is permissions: Drupal won't allow you to upload a file not in the files directory.

Here is how I do it:

(1) In your test, create a function `$this->prepareFileForUpload($path)` which you can define as such:

		...
		/**
		 * Prepare a file for use in an $edit array of a drupalPost()
		 *
		 * See http://blog.dcycle.com/blog/78
		 *
		 * @param $path
		 *   A path in your module such as sites/all/modules/mymodule/test.png
		 *
		 * @return
		 *   A path suitable for passing to drupalPost(), for example:
		 *   '/www/drupal/sites/default/files/simpletest/420915/test.png'
		 */
		function prepareFileForUpload($path) {
			// Figure out the full filepath
			$filepath = DRUPAL_ROOT . '/' . $path;

			// move the contents of the file to the public stream.
			$contents = file_get_contents($filepath);
			$dir = 'public://';
			if (!file_prepare_directory($dir) && !drupal_mkdir($dir)) {
				throw new Exception('Directory ' . $dir . ' could not be created, check permissions');
			}
			// see http://stackoverflow.com/questions/1361741
			$uri = $dir . substr($path, strrpos($path, '/')+1);
			if (!file_exists($uri)) {
	      $file = file_save_data($contents, $uri);
				return drupal_realpath($file->uri);
			}
			throw new Exception('Could not create the file');
		}
    ...

(2) then in your test call:

    ...
    $edit = array(
    	...
    	['myfield'] =>  $this->prepareFileForUpload('sites/all/modules/mymodule/test-files/my-test-file.png'),
    	...
    );
		$this->drupalPost('my/module/path', $edit, 'Save');
		...
