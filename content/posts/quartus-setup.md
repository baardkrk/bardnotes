---
title: "Quartus Setup on Linux"
date: 2020-03-06T15:38:59+01:00
draft: true
---

Setting up Quartus on linux
===============

I had some problems setting up Quartus on ubuntu 16.04, so here's a short tutorial.
My board is a DE10-Lite, and I'm using the Linux edition of [Quartus Prime Lite][1], 18.1
update 646. 
I'm writing this quite a while after the fact, but I seem to remember that I had to register
an account to download the software.
The installation seemed to go without issue if I remember correctly, but that ended when I
tried to program my board.

Quartus was able to initialize the sequence, but encountered a JTAG problem. The
load-indicator-led on the board also lights up when quartus starts the programming, but
then gives up when the programmer encounters the error:
```
209040 Can't Access JTAG chain
```

I tried running the JTAG-chain debugging tool, but it also just hangs for a couple of
minutes, and then, nothing happens. 

The main problem was that I got a USB Blaster JTAG issue. 

Solution
---------
I initially followed [a tutorial][2] however it has been removed, so I'll reiterate it
here. (Much of the text will be a direct copy of the original, written by Eric LaForest) 

********************************************************************************************

The solution is to allow `jtagd` to run as `root` to ensure sufficient permissions.

### Create udev rule
We have to create a new `udev` rule in `/etc/udev/rules.d/51-altera-usb-blaster.rules`: 
```
# USB-Blaster
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"
# USB-Blaster II
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"
```
Then, reload the file using
```
$ udevadm control --reload
```

### Allow non-root access to the USB-blaster device
Create a file called `altera-usb-blaster.rules` in `/etc/udev/rules.d/` containing a
single line:
```
ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="666"
```
This grants `rw-rw-rw-` permissions to the device. A more proper configuration involves
creating a group for the device, say `usbblaster`, placing your user(s) in that group, and
defining the device permissions:
```
ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", GROUP="usbblaster"
```
*Note that this is not perfect: multiple USB device entries will be created for the
USB-Blaster, and not all will have the new permissions, which is why `jtagd` must run as
root.*

### Configuring `jtagd`
Quartus uses a daemon, `jtagd`, as an intermediate between the programming software and
the device. This seems needlessly complicated, but does enable remote host programming,
apparently. The key points to configuring it correctly are: it must be able to access a
list of FPGA descriptions and run as `root`.

Copy the descriptions from your Quartus installation to the configuration directory of
`jtagd`:
```
$ mkdir /etc/jtagd
$ cp <QUARTUS INSTALL PATH>/linux/quartus/pgm_parts.txt /etc/jtagd/jtagd.pgm_parts
```
*Note the change of the name in the second command!*

Then, have `jtagd` start at boot by either placing it in the `rc.d` system, or simply
place the following line in `/etc/rc.local`:
```
<QUARTUS INSTALL PATH>/linux/quartus/bin/jtagd
```

Although it might get created automatically, you can create an empty file named
`.jtagd.conf` in your home directory. I hear it's possible to edit it to allow external
hosts to connect and program/debug. This is only neccessary if you want to use that
feature.

### Testing your setup
As a final test, plug in your device, run `$ dmesg` to see if the USB-Blaster device is
found, then run (as your usual user) `$ jtagconfig`. You should see some similar output to
this:
```
1) USB-Blaster [USB 1-1.1]
  020B30DD   EP2C15/20
```
If USB device permissions are insufficient, (they shouldn't given the rule you added in
`/etc/udev/rules.d/altera-usb-blaster.rules`) you will instead get
```
No JTAG hardware available
```
If USB permissions are OK, but `jtagd` is not running as `root`, you'll see:
```
1) USB_Blaster [USB 4-1.2]
  Unable to lock chain (Insufficient port permissions)
```
Finally, if permissions are OK and `jtagd` is running as root, but it cannot access the
FPGA device descriptions, you will see:
```
1) USB-Blaster [USB 4-1.2]
  024030DD
```
********************************************************************************************

I continued to have some problems, so my final fix was to follow [this answer][3].
This is if you still get something like `JTAG chain broken`. It seems to solve the problem
if you download `libudev1:i368` and create a symbolic link:
```
$ sudo apt-get install libudev1:i386
$ sudo ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
```

Hopefully this works for whoever else reads this!


[1]: https://fpgasoftware.intel.com/?edition=lite
[2]: http://fpgacpu.ca/fpga/USB-Blaster-Debian.html
[3]: https://electronics.stackexchange.com/questions/239882/altera-cyclone-ii-jtag-after-as-programming

