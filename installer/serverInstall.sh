#!/bin/bash

set -e 

#if [ -a /var/lib/dpkg/lock ]; then
#	echo "Something else is already using apt-get. Please wait for other things to install and try again. "
#	exit 1;
#fi

if [[ $EUID -ne 0 ]]; then
   clear
   # echo -e "Launching Installer..."
   cp serverInstall.sh /tmp/serverInstall.sh
   gksudo -D "FAIMS server" -m "Please enter your password to install the FAIMS Server" "gnome-terminal -x bash /tmp/serverInstall.sh"
   sleep 10
   echo -n "Now launch the faims server in a browser by going to http://localhost:3000 "
  
fi


# echo -e "Installing prgress bars. Go get a coffee, this install will take a while."
apt-get -y install software-properties-common pv || { echo "apt-getting failed. exiting..."; exit 1; }

if ! ls /etc/apt/sources.list.d/faims-mobile-web-*.list 2> /dev/null 1> /dev/null
	then add-apt-repository ppa:faims/mobile-web -y
		 add-apt-repository ppa:ubuntugis/ppa -y 
fi

# echo -e "Updating Package List."
apt-get update 
apt-get upgrade -y 
apt-get install unzip build-essential g++ gawk libreadline6-dev bison pkg-config git-core wget curl expat libexpat1-dev zlib1g-dev libyaml-dev libxslt1-dev libgdbm-dev libncurses5-dev libffi-dev d-shlibs dh-autoreconf libblas3gf libepsilon-dev liblapack3gf libogdi3.2-dev python-all python-all-dev python-central python-dev python-numpy python2.7-dev libproj-dev libproj0 libgeos-dev libgeos++-dev libfreexl-dev tcl tcl-dev libreadosm-dev sqlite3 gdal-bin -y 
apt-get build-dep libspatialite-dev -y

echo "select sqlite_version();" | sqlite3 :memory: -line | grep 3.7.17 || { echo "sqlite3 wrong version. exiting." ; exit 1; }

echo "Downloading other files"

wget http://www.fedarch.org/libspatialite-4.1.1.tar.gz http://www.fedarch.org/spatialite-tools-4.1.1.tar.gz -P /tmp/ || { echo "downloads failed. exiting." ; exit 1; }
wget http://www.fedarch.org/master.zip -P /opt/ || { echo "downloads failed. exiting." ; exit 1; }
# echo -e "Upgrading System Packages."


# echo -e "Preparing to Compile Packages."



# echo -e "Downloading & Installing Packages"


cd /tmp/

# ln -s /usr/lib/tcl8.5 /usr/lib/`dpkg-architecture -qDEB_BUILD_GNU_TYPE`/tcl8.5

# apt-get -b source sqlite3

# dpkg -i *.deb

echo "export rvm_trust_rvmrcs_flag=1" >> /etc/rvmrc
echo "export rvm_autolibs_flag=3" >> /etc/rvmrc

cd /tmp/

# echo -e "Downloading Spatialite and its tools."

tar -xzf libspatialite-4.1.1.tar.gz
tar -xzf spatialite-tools-4.1.1.tar.gz 

# echo -e "Compiling Spatialite."

cd /tmp/libspatialite-4.1.1

./configure | pv -p -s 9656 -e > /tmp/compile1.log
make | pv -p -s 115351 -e > /tmp/compile2.log
make install | pv -p -s 15628 -e > /tmp/compile3.log

cd /tmp/spatialite-tools-4.1.1

./configure | pv -p -s 8154 -e > /tmp/compile4.log
make | pv -p -s 8195 -e > /tmp/compile5.log
make install | pv -p -s 1501 -e > /tmp/compile6.log


ldconfig



# echo -e "Installing RVM. All instructions in the following text have been taken care of."
\curl -# -L https://get.rvm.io | bash -s stable --ruby=1.9.3-p286 --autolibs=3 > /tmp/rvm 2> /tmp/rvmerror

# echo -e "Setting up correct groups and profiles."

usermod -a -G rvm $SUDO_USER
usermod -a -G rvm root


# echo "RAILS_ENV=production" >> /etc/profile.d/rvm.sh
source /etc/profile.d/rvm.sh


if ! grep rvm.sh /etc/bash.bashrc 1> /dev/null 2> /dev/null
    then echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc
fi


rvm requirements

rvm 1.9.3-p286@faims --create
# install ruby-1.9.3-p286

# rm -rf /opt/faims

cd /opt/

# echo -e "Downloading the FAIMS Server."


unzip -q master.zip

mv /opt/faims-web-master /opt/faims-web
rvm rvmrc warning ignore /opt/faims-web/.rvmrc



cd /opt/faims-web/

# rvm 1.9.3-p286@faims --create --rvmrc

# echo -e "Installing rvm gemsets. This will take a while."
bundle install 

# echo -e "Setting up Server. This will take a while."
rake db:drop db:create db:migrate db:seed modules:clean modules:setup assets:precompile RAILS_ENV=production

# chmod -R a+wx /opt/faims-web


foreman export upstart /etc/init -a faims-web -u $SUDO_USER -f Procfile.production

start faims-web

chown -R $SUDO_USER:root /opt/faims-web

chmod -R a+rw /opt/faims-web

sed -i '1istart on runlevel 5' /etc/init/faims-web.conf
