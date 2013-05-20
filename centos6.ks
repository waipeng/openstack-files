install
text
key --skip
keyboard us
lang en_US.UTF-8
skipx
network --device eth0 --bootproto dhcp
rootpw changeme
firewall --disabled
authconfig --enableshadow --enablemd5
selinux --enforcing
timezone --utc Asia/Singapore
bootloader --location=mbr --append="console=tty0 console=ttyS0,115200"
zerombr yes
clearpart --all

part /boot --fstype ext4 --size=200
part swap --size=512
part / --fstype ext4 --size=1024 --grow

user --name os-user --password changeme --plaintext --groups wheel

repo --name=epel --baseurl=http://mirror.nus.edu.sg/fedora/epel/6/x86_64/
reboot

%packages
@core
@base
cloud-init

%post

# install EPEL repo
rpm -Uvh http://mirror.nus.edu.sg/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

# let's clean it up a bit
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# reference partitions by /dev instead of UUID
sed -i 's,UUID=[^[:blank:]]* /\ ,/dev/vda3               / ,' /etc/fstab
sed -i 's,UUID=[^[:blank:]]* /boot,/dev/vda1               /boot,' /etc/fstab
sed -i 's,UUID=[^[:blank:]]* swap,/dev/vda2               swap,' /etc/fstab

# create the default user instead of root
sed -i 's/^user: ec2-user/user: os-user/' /etc/cloud/cloud.cfg
# allow user to sudo
sed -i 's/# %wheel\tALL=(ALL)\tALL/%wheel\tALL=(ALL)\tALL/' /etc/sudoers
#sed -i 's/^disable_root: 1/disable_root: 0/' /etc/cloud/cloud.cfg

rm -f /root/anaconda-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog
find /var/log -type f -delete
