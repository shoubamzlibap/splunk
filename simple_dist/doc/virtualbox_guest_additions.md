# Install Virtualbox Guest Additions

```
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install gcc kernel-devel kernel-headers dkms make bzip2 perl

KERN_DIR=/usr/src/kernels/`uname -r`/build

```
