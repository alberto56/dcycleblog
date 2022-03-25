---
layout: post
title:  "Installing Docker for Windows (not for the faint of heart)"
author: admin
id: 2022-03-24
tags:
  - blog
permalink: /blog/2022-03-24/installing-docker-for-windows/
redirect_from:
  - /blog/2022-03-24/
  - /node/2022-03-24/
---

Here is how to use Docker Desktop for Windows. This has been tested on a Windows 10 Pro (Supposedly if you're using Windows 10 Home, you're out of luck) HP EliteBook with 16 Gb or RAM. (I have found that on machines with less RAM certain errors can occur when dealing with multiple containers.)

If you have installed Docker Desktop for macOS or for Linux, note that installing it for Windows has many, _many_ more steps, so you'll want to set aside at least an hour to get it up and running. You will need to fiddle with the heart of your computer and undergo numerous restarts. Have coffee handy, as well as sweets.

Let's get started
-----

Download the Docker Desktop Installer.exe from https://docs.docker.com/desktop/windows/install/

Run the installer, and answer "Yes" to all the questions.

In the Configuration screen, check:

* Install required Windows components for WSL 2 (WSL means "Windows Subsystem for Linux", that's a good thing).
* Add shortcut to Desktop (always handy).

The installation can take several minutes, and you will have to restart your computer when you're finished.

**Do not launch Docker quite yet! We must set up a few things first!**

Make changes in the BIOS
-----

You will need to make sure "Hardward assisted virtualization" and "data execution prevention" (which I've also seen referred to as "data execution protection", which I think is a mistake but what do I know) are enabled in the BIOS, here is how:

**Restart your computer** and **immediately press the DEL or "delete" key, leaving it pressed until you get a menu on your screen, including an option for BIOS Setup**. (The Delete key is not the backspace key, on an HP laptop is it at the upper-right of the keyboard.)

Enter BIOS Setup (can be by pressing F10), then find "Virtualization Technology (VTx)" and "data execution prevention" (on my laptop this is in Advanced Settings, then Device Configuration) and enable them.

Exit the BIOS config tool, save, and your computer will restart.

Install the WSL 2 Linux Kernel
-----

Go to https://aka.ms/wsl2kernel, which should redirect to a Microsoft site where you can download the WSL2 Linux Kernel Update Package for x64 machines.

Execute the file which runs you through an installation wizard, answer Yes to all questions.

Restart your computer.

Setting up your computer to use Docker
-----

Once your computer is restarted (again), in the Start menu, find "Control Panel", then "programs", and "Programs and features", then, in the sidebar, "Turn Windows features on or off".

Make sure the following are checked:

* Virtual Machine Platform
* Windows Subsystem for Linux
* Hyper-V and its two children

Then save.

You're now ready to start Docker
-----

You probably already know this won't work, so you'll need to brush off your Googling skills because you'll need to do a deep dive in Reddit threads and StackOverflow questions.

But maybe this is your lucky day (lucky days do exist you know):

**Launch the Docker App**

I will assume you got no errors.

Running your first Docker container
-----

In the Start menu, go to the Command Prompt, then type in exactly:

    docker run -d -p 80:80 docker/getting-started

It should say:

    Unable to find image 'docker/getting-started'

The word "Unable" might throw you off, but this actually means everything is working perfectly (I actually [opened a ticket to request that this wording be changed, because of the number of people telling me "Docker deosn't work" because they misinterpreted the word "Unable"](https://github.com/moby/moby/issues/42283))!

You might then get a "Windows Security Alert", and you'll need to allow access.

This command should have started a container which will be accessible on port 80 (the default port). (If you're a power user and your port 80 is already in use on your machine, use 8888:80 instead of 80:80, which will make your container publish a web page on port 8888 instead of 80.

To make sure your conatiner is actually really running, type:

    docker ps

You should see something like:

    b028a2bfd08a   docker/getting-started   "/docker-entrypoint.…"   11 seconds ago   Up 11 seconds   0.0.0.0:80->80/tcp     beautiful_pike

Docker assigns a unique ID and random name to your running container, in my case the name is "beautiful_pike" but yours will be different.

Assuming your container is using port 80, open a browser and type in the URL:

    http://localhost

If you're using a port other than 80, you can use (for example for 8888):

    http://localhost:8888

You should now see a tutorial page which is running on your container, called "Getting Started".

Now you can destroy your running container by typing:

    docker kill beautiful_pike

(Your container's name will be different, as discussed above.)

There's lots more to learn about Docker, which is out of scope for this article, but now that you have Docker working, you can do a bunch of cool things like:

    docker run --rm msoap/ascii-art cowsay 'Happy Coding, Cowperson'

Which will display a cow:

    _________________________
    < Happy Coding, Cowperson >
    -------------------------
           \   ^__^
            \  (oo)\_______
               (__)\       )\/\
                   ||----w |
                   ||     ||

Troubleshooting
-----

If you are having issues with Docker Desktop for Windows, I suggest you do the following:

* Update to the latest version of Windows
* Update to the latest version of Docker (I'll let you figure that out on your own!)
* Reset to factory defaults of Docker (That's in the "bug" section of the Dashboard of Docker Desktop)
* Check [the Docker troubleshooting page](https://docs.docker.com/desktop/windows/troubleshoot/) which might have further tips.
* Get more RAM or figure out how to add RAM limits in your .wslconfig file (no one said this would be a walk in the park)

Resources
-----

* [Hyper-V Virtualisation Disabled in Firmware, SuperUser, answer by Augustus Francis, edited by Glorfindel](https://superuser.com/a/648237)
* [Docker for Windows error: "Hardware assisted virtualization and data execution protection must be enabled in the BIOS", answer by Silverstorm](https://stackoverflow.com/a/39989990/1207752)
