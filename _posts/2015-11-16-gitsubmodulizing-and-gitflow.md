---
layout: post
title: Gitsubmodulizing and Gitflow
author: admin
id: 105
created: 1447695985
tags:
  - blog
permalink: /blog/105/gitsubmodulizing-and-gitflow/
redirect_from:
  - /blog/105/
  - /node/105/
---
Gitflow is a development workflow we use where all features are developed on their own branch, and we constantly merge in the mainline (in this example it will be `master`) to the feature branches, until the feature branches are ready, at which point they are merged into master. One thing to remember: we're not supposed to merge branch `feature/a` into `master` unless `master` is merged into `feature/a`.

Here is a simplified version of the situation I was facing.

First, we had a simple git repo, like this:
-----

    cd ~
    mkdir myrepo
    cd myrepo
    mkdir externalsoftware
    touch externalsoftware/README.txt
    git init
    git add .
    git commit -am 'my repo with external software'

We've included external software in our repo directly, not as git submodules, composer or anything else. This external software does exist somewhere else:

    cd ~
    mkdir externalsoftware
    cd externalsoftware
    touch README.txt
    git init
    git add .
    git commit -am 'external software'

Gitsubmodulizing a directory
-----

Later on, we realized that it might be more elegant to not track the entire contents of the external software in our git repo, but just track the external software's git repo address and the commit number we're using. This can be done with git submodules. We did this on a feature branch of our initial project:

    cd ~
    mkdir myrepo
    cd myrepo
    git checkout -b feature/submodulize
    git rm -r externalsoftware
    git commit -am 'removing external software with the intention of adding it later as submodule'
    git submodule add ~/externalsoftware externalsoftware
    git commit -am 'added external software as a submodule'

The line:

    git submodule add ~/externalsoftware externalsoftware

might not be immediately obvious. What we're saying that we want to use an external repo (in this case `~/externalsoftware`, but normally you'd supply the full URL) and place it within our own repo at `externalsoftware`.

OK, now that we've added a git submodule to our repo, we need to add some more steps to "build" our software when we clone it. We can do this in a "build.sh" script, like this:

    echo "git submodule init" > build.sh
    echo "git submodule update" >> build.sh
    chmod +x build.sh
    git add .
    git commit -am 'Added build script'

Let's try it:

    cd ~
    git clone myrepo newinstall
    cd newinstall
    ls -lah externalsoftware

Hmmm, when you first clone your project, externalsoftware will be empty:

    total 0
    drwxr-xr-x  2 albert  staff    68B 16 Nov 08:04 .
    drwxr-xr-x  5 albert  staff   170B 16 Nov 08:04 ..

Let's use the `build.sh` script we created earlier.

    ./build.sh

You'll see that it grabbed externalsoftware from its repo. If you run git log on `~/externalsoftware`, you will notice that the commit hashes match (yours will be different, though).

    ...
    Submodule path 'externalsoftware': checked out 'b223084c810b01294302fbe2cbe839cc2b1635f6'
    ...

Now, our external software is ready to be used:

    $ ls -lah externalsoftware/
    total 8
    drwxr-xr-x  4 albert  staff   136B 16 Nov 08:06 .
    drwxr-xr-x  6 albert  staff   204B 16 Nov 08:06 ..
    -rw-r--r--  1 albert  staff    41B 16 Nov 08:06 .git
    -rw-r--r--  1 albert  staff     0B 16 Nov 08:06 README.txt

Merging
-----

If you try checkout out master, you'll get the error:

    cd ~/myrepo
    git checkout master
    error: The following untracked working tree files would be overwritten by checkout:
      externalsoftware/README.txt

To avoid this, let's delete all files in our `./externalsoftware` folder, because we can always use the `./build.sh` script to recreate them (this will not change the status of your repo, as you can see if you run `git status`).

    rm -rf externalsoftware

OK, now we can checkout master and add a new feature to master:

    git checkout master
    touch newfeature.txt
    git add .
    git commit -am 'added new feature'

The merge vortex
-----

Merging master into feature/submodulize does work.

    git checkout feature/submodulize
    git merge master

    CONFLICT (file/directory): There is a directory with name externalsoftware in master. Adding externalsoftware as externalsoftware~HEAD
    Automatic merge failed; fix conflicts and then commit the result.

Ouch! I have tried fixing this conflict in various ways:

    git submodule add ../externalsoftware/ externalsoftware/
    'externalsoftware' already exists in the index

and...

    git commit -am 'added newfeature'
    error: unable to index file externalsoftware
    fatal: updating files failed

I finally abdicated:

    git reset --hard

We could try the other way around, but it goes against the best practices of GitFlow, the development workflow we're using. However, I'm still allowed to create a new branch off master, then merge feature/submodulize in that new branch:

    git checkout master
    git checkout -b master-temp
    git merge feature/submodulize

The merge _seems_ to have worked, except...

    git status
    # On branch master-temp
    # Changes not staged for commit:
    #  (use "git add/rm <file>..." to update what will be committed)
    #  (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #  deleted:    externalsoftware

It turns out that `externalsoftware` was deleted. But we can now try our `./build.sh` script:

    ./build.sh
    git status
    # On branch master-temp
    # nothing to commit, working directory clean

That seems right, although now we're stuck with working code on `master-temp`, not on `feature/submodulize`. Now all we have to do is to merge `master-temp` into `feature/submodulize`:

    git checkout feature/submodulize
    git merge master-temp
    git branch -d master-temp

Now `master` is fully merged into `feature/submodulize`, which is what Gitflow requires.

    git merge master
    # Already up-to-date.

Now, we can run `feature/submodulize` on our continuous integration server, run a preprod environment to show stakeholders, etc., knowing that it contains the very latest version of `master`.

When we're ready to merge `feature/submodulize` into master, not a problem (assuming that no more great features were added to master in the meantime!):

    git checkout master
    git merge feature/submodulize
    git status
    # On branch master
    # nothing to commit, working directory clean
    ./build.sh
    # Submodule path 'externalsoftware': checked out 'b223084c810b01294302fbe2cbe839cc2b1635f6'

Voilà!

A note on Git submodules
-----

The easiest way of including external code in your git repo is to just copy it there. This "just works", but has a few drawbacks:

 * When your code is peer-reviewed, a lot of extra code pollutes your actual changes. The relevant change, in this case, is that we're using commit b223084 of some external source (~/externalsoftware), not the actual contents of `~/externalsoftware`. (Of course, during your code review process, you should also make sure that `~/externalsoftware` complies with your organization's security and maintenance policy, but it's not actual code that should be reviewed line by line in the same way your custom code is.
 * Git repos can get bloated, although this has never been a problem for me.
 * Especially, some hapless developer might hack the external library which now resides in your git repo. This requires you to add a step to your "update external code" checklist to make sure it hasn't been hacked. This is not possible if you reference it instead of including it.

Git submodules are a solution to this, although not as foolproof as other features of git:

 * The commands are not intuitive (to me at least).
 * Gitsubmodulizing or Ungitsubmodulizing a directory can be a pain, as can attest a lot of late-night posts to Stackoverflow and the like.
 * What if the maintainer of `~/externalsoftware` decides that git submodules are great too?

Here's what that would look like, if you're interested (for the sake of simplicity we'll not be using Gitflow for this):

    cd ~
    mkdir externaltoexternal
    cd externaltoexternal
    touch README.txt
    git init
    git add .
    git commit -am 'external to external software'

    cd ~/externalsoftware/
    git submodule add ../externaltoexternal externaltoexternal
    git commit -am 'add some external software'

    cd ~/myrepo/
    git checkout master
    cd externalsoftware/
    git pull origin master
    cd ..
    git commit -am 'updated external software'

In this case you would also have to update your `./build.sh` to also fetch `externalsoftware`'s git submodules:

    echo 'cd externalsoftware && git submodule init && git submodule update' >> build.sh
    git commit -am 'updated build script'

Let's try building this now:

    rm -rf externalsoftware/
    ./build.sh
    # Submodule path 'externalsoftware': checked out       
    # 'e546535b47c1f7231cc4fae58f63f0bd44ef5ca6'
    # Submodule 'externaltoexternal' (/Users/albert/externaltoexternal) registered for path 'externaltoexternal'
    # Cloning into 'externaltoexternal'...
    # done.
    # Submodule path 'externaltoexternal': checked out 'f94de5207ff3f88046b591232fd89171cf0edfb1'

That works, but you can see that the complexity of Git submodules requires a lot more investment on the part of developers to understand all this stuff.

Git submodules, also, are not the only game in town: makefiles, composer, phing are tools that might work for you as well.

Cleaning up after our experiment
-----

If you followed along, now's the time to delete dangling folders from your computer:

    rm -rf ~/myrepo
    rm -rf ~/externalsoftware
    rm -rf ~/externaltoexternal
    rm -rf ~/newinstall
