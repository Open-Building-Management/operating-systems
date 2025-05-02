To use buildroot, you have to install ncurses and graphviz :

```
sudo apt-get install libncurses5-dev libncursesw5-dev
sudo apt install graphviz
```

See [buildroot](https://buildroot.org/downloads/manual/manual.html#requirement-mandatory) fro a list of all required dependancies


# X86_64

testing the disk.img produced with qemu

```
qemu-system-x86_64 -M pc -bios /usr/share/ovmf/OVMF.fd -drive file=disk.img,if=virtio,format=raw -net nic,model=virtio -net user
```

if qemu not installed : `sudo apt install qemu-systems`

You have to find your OVMF.fd file on your computer. Found a folder `ovmf` in `/usr/share`



