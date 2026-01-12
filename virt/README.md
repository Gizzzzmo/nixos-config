# Virtualisation

https://gist.github.com/mag37/7be87af23a75eb7e6c6193ca93812d26

[This file](./windows-guest.xml) contains a virt-manager configuration for a windows VM with 96 GB storage, 6 virtual cpus, and 12 GB RAM.
To install Windows on it you will need an appropriate image, and virtio drivers, both of which must be mounted as CDs during installation.
The config already has SATA CDROM devices for both, but the paths are probably wrong.
It also contains configuration for a virtual volume, which will have to be overwritten (and a new virtual volume will have to be created in its place).

During installation when selecting the disk to install Windows on you will need to first select "Load Driver", and then navigate to amd/win11 on the disk containing the virtio drivers. Once the driver is installed the disk should be visible.

If at any point the VM doesn't want to boot anymore because of an error related to `efi firmware` then you need to create a new VM, that can boot, and, from its xml config, copy over the `<os></os>` block.
