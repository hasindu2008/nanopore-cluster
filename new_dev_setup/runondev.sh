if [ "$EUID" -ne 0 ]
  passwd 
  then echo "Please run as root for the rest"
  exit
fi

if [ "$#" -ne 1 ]; then
    echo "usage : $0 <devname>"
        exit
fi


device=$1
echo $device > /etc/hostname
sed -i "s/rock64/$device/" /etc/hosts

#echo "Australia/Sydney" > /etc/timezone
#dpkg-reconfigure --frontend noninteractive tzdata
dpkg-reconfigure tzdata
echo "NTP=ntp1.unsw.edu.au" >> /etc/systemd/timesyncd.conf
echo "server ntp1.unsw.edu.au" >> /etc/ntp.conf

apt-get update && sudo apt-get upgrade -y
apt-get install -y time nfs-common ganglia-monitor python


echo "10.0.0.5:/volume1/homes/        /mnt    nfs     intr,nfsvers=3,rsize=8192,wsize=8192       0       0"  >>  /etc/fstab

dd if=/dev/zero of=/swapfile bs=1024 count=2097152
mkswap /swapfile
swapon /swapfile
chmod 600 /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

mkdir /nanopore
 scp -r rock64@10.40.18.2:/nanopore/* /nanopore/
chown rock64 /nanopore -R
