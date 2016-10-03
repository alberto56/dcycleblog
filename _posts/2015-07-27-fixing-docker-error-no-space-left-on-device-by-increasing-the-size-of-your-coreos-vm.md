---
layout: post
title: 'Fixing "Docker error : no space left on device" by increasing the size of
  your CoreOS VM'
author: admin
id: 99
created: 1437961285
tags:
  - blog
permalink: /blog/99/fixing-docker-error-no-space-left-device-increasing-size-your-coreos-vm/
redirect_from:
  - /blog/99/
  - /node/99/
---
You might get this error especially with very large projects. We are assuming that your setup is:

 * Your local "bare metal" computer (can be any OS).
 * CoreOS running on Vagrant and VirtualBox.
 * Containers running via Docker on CoreOS.

We are assuming also that you have sufficient free space on your local computer.

Start by confirming that your bare metal computer has sufficient space:

    df -h /
    Filesystem   Size   Used  Avail Capacity   iused    ifree %iused  Mounted on
    /dev/disk1  465Gi  403Gi   61Gi    87% 105788027 16058281   87%   /

Here, we have 61G available. Make sure that this is enough for your project by adding free space to your laptop.

Next, `ssh` into your CoreOS virtual machine and perform the same operation.

    $ df -h /
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda9        16G  7.7G  7.2G  52% /

In this case we have 7.2G available on CoreOS with a total of 16G. If this is insufficient for your project, start by installing [this script](https://gist.github.com/michaelneale/1366325a7737c4cb80b0) on your CoreOS box, and run it to remove unused containers and images.

If that is not enough, you will need to increase the size of your VM. Here is how.

Start by backing up all important data on your VM and destroying it:

    vagrant destroy

Now, locate the `.vmdk` image you're using, it should be something like:

    ~/.vagrant.d/boxes/coreos-alpha/752.1.0/virtualbox/coreos_production_vagrant_image.vmdk

Changing its size is a painful process, and involves converting the box to another format, but the following commands should do it (taken from this [GitHub issue](https://github.com/mitchellh/vagrant/issues/2339)):

    cd ~/.vagrant.d/boxes/coreos-alpha/752.1.0/virtualbox/
    VBoxManage clonehd coreos_production_vagrant_image.vmdk temp.vdi --format vdi
    VBoxManage modifyhd temp.vdi --resize 61440
    VBoxManage clonehd temp.vdi resized-disk.vmdk --format vmdk
    rm coreos_production_vagrant_image.vmdk temp.vdi
    mv resized-disk.vmdk coreos_production_vagrant_image.vmdk

Now, re-`vagrant up` your box and log into it:

    vagrant up
    vagrant ssh

You should be seeing more memory:

    df -h /
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda9        56G   23M   54G   1% /

Rebuild your Docker container and you should no longer be seeing the `Docker error : no space left on device` error.
