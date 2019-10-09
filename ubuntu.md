[Link](https://medium.com/@nitinpatel_20236/fixing-the-problems-installing-ubuntu-on-asus-rog-laptop-asus-gl503ge-5b6f497201b8)

# Installing ubuntu on my laptop model

Summary:

Step 5:

Once you’re in, go to the line starting with ‘Linux …’ and insert ‘nouveau.modeset=0’ without quotes at the end of that line, (after quiet splash).

Now you can click F10 to boot into Ubuntu, you will get the installation n without for Ubuntu. Follow the instructions and install Ubuntu into the partition you created.

After installation, it will prompt you to restart your computer. Do NOT Restart it just yet. Before you do that you need to update your Nvidia graphics drivers.

(*In case you accidentally hit restart, you need to do step 4 and 5 again. Just that you don’t need to reinstall the OS, just start it with the ‘nouveau.modeset=0’ grub configuration.)
Step 6:

Now, Go to the software update application and search for driver updates. You must see two options. Select the option to update the Nvidia drivers (one without the X.org) and click apply. Once the installation is complete is done, you can restart your system.

# Getting the Touchpad/Trackpad to Work

```
sudo add-apt-repository ppa:teejee2008/ppa 
sudo apt-get update 
sudo apt-get install ukuu
```

`/usr/local/bin/rsmod/hid-multitouch`:
```
#!/bin/bash
if [ -z $1 ]
    then
        echo 'rsmod unloads and reloads kernel modules with modprobe'
        echo 'usage: rsmod <kernelmodulename>'
        echo 'Requires root privileges'
        exit 1
fi
pkexec bash -c "modprobe -r $1; modprobe $1"
```

# Or

I have this machine running under Linux and various flavors. Here are some tips. Message me or reply here if you have trouble with the below because I am doing this from memory.

Kernels below 4.3 (pretty much any distro at the end of December): Add "nouveau.modeset=0 tpm_tis.interrupts=0 acpi_osi=! acpi_backlight=native i915.preliminary_hw_support=1 idle=nomwait"

The Nouveau command disables the NVidia card, which you need to do until you get proper drivers installed (use something like Bumblebee).
The ACPI commands make your keyboard hotkeys work properly
The i915 command tells the older kernel to use the "beta" Skylake support, which you will certainly want.
The idle command is needed to make the new Skylake chipset speed up and down properly without locking up. I was seeing occasional lockups without the idle setting.

With these settings, I have full function keys, screen lighting, etc, the cpu is at full speed and everything works great EXCEPT I have no touchpad support. As far as I can tell, the kernel does not support the touchpad in this machine/configuration at present. There are multiple bugs raised within the Linux community if you look around. I am hoping we will see a fix to this soon. I tried to debug the device but due to lack of time I don't think I will be able to find a fix on my own.

After install, set X windows up to not use the NVidia drivers and you can drop the nouveau.modeset parameter. I use the Mesa open source drivers.

For 4.3 and above kernels (which I have custom compiled from source at this point but should be rolling out on some distros soon) you can drop the i915.preliminary_hw_support and tpm_tis.interrupts. You don't need those on the latest kernel as far as I can tell.

Don't use things like "nolapic" and other stuff you read on the internet because all that does is drop you down to one core and limit your hardware significantly. Might as well not have the new computer if you use those things.

FWIW I think Elementary OS's latest ISO works "out of the box" with only the nouveau.modeset=0 directive. Also, it was kind of tricky to get Arch Linux to work with my home wifi due to WPA based encryption. I got it working, but if you have a similar setup be advised it took a little time to get the commands right with this wireless card.

If you are a developer or familiar with the tools for some other reason, you can build your 4.3 kernel and its faster. Download the latest sources and find a guide online for building the kernel. It took me some time to build and run the new kernel but it did allow me to get better utilization of the CPU and graphics card.