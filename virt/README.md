# Virtualisation

https://gist.github.com/mag37/7be87af23a75eb7e6c6193ca93812d26

[This file](./windows-guest.xml) contains a virt-manager configuration for a windows VM with 96 GB storage, 4 virtual cpus, and 12 GB RAM.
To install Windows on it you will need an appropriate image, and virtio drivers, both of which must be mounted as CDs during installation.

During installation when selecting the disk to install Windows on you will need to first select "Load Driver", and then navigate to amd/win11 on the disk containing the virtio drivers. Once the driver is installed the disk should be visible.
