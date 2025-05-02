# X86_64

testing the disk.img produced with qemu

```
qemu-system-x86_64 -M pc -bios /usr/share/ovmf/OVMF.fd -drive file=disk.img,if=virtio,format=raw -net nic,model=virtio -net user
```

if qemu not installed : `sudo apt install qemu-systems`

You have to find your OVMF.fd file on your computer. Found a folder `ovmf` in `/usr/share`



