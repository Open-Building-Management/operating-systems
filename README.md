# operatings-systems

This project uses buildroot, which requires ncurses and graphviz :

```
sudo apt-get install libncurses5-dev libncursesw5-dev
sudo apt install graphviz
```

See [buildroot](https://buildroot.org/downloads/manual/manual.html#requirement-mandatory) for a list of all required dependancies


```
git clone --recurse-submodules https://github.com/Open-Building-Management/operating-systems.git
cd operating-systems
```

If already cloned without --recurse-submodules :

```
git submodule init
git submodule update
```

To compile a defconfig

```
make obm_x86_64_efi_defconfig
make
```

`disk.img` will be in `output/images/`

Usage :
- Create a Ubuntu live operating system on a USB flash drive
- Create a subfolder `ìmages` on the USB flash drive
- Copy `disk.img` in the `ìmages` subfolder 
- Insert the USB flash drive into the target system (eg laptop thinkpad X13)
- Boot the live operating system and select try ubuntu
- In the applications, search and open **Disks**, choose the target hdd and start restoring the image


