#!/bin/bash



if [[ $EUID -ne 0 ]]; then
   clear
   echo -e '\E[37;44m'"\033[1mLaunching Installer...\033[0m"
   cp serverInstall.sh /tmp/serverInstall.sh
   gksudo -D "FAIMS server" -m "Please enter your password to install the FAIMS Server" "bash /tmp/serverInstall.sh"
   echo -n "Now launching faims server in a browser."
   pgrep unicorn > /dev/null
   while [ $? -ne 0 ]; do
   	echo -n .
   	sleep 1
   	pgrep unicorn
   done 
   sensible-browser http://localhost:3000 &
   exit 1
fi

echo progress-bar >> ~/.curlrc

echo -e '\E[37;44m'"\033[1mInstalling prgogress bars. Please wait.\033[0m"
apt-get -qq -y install software-properties-common pv
add-apt-repository ppa:faims/mobile-web -y >> /tmp/repo.log 2> /tmp/err
add-apt-repository ppa:ubuntugis/ppa -y >> /tmp/repo.log 2>> /tmp/err

echo -e '\E[37;44m'"\033[1mUpdating Package List.\033[0m"
apt-get update

echo -e '\E[37;44m'"\033[1mDownloading & Installing Packages\033[0m"
apt-get install unzip build-essential g++ gawk libreadline6-dev libsqlite3-dev bison pkg-config git-core wget curl expat libexpat1-dev zlib1g-dev libyaml-dev libxslt1-dev libgdbm-dev libncurses5-dev libffi-dev d-shlibs dh-autoreconf libblas3gf libepsilon-dev liblapack3gf libogdi3.2-dev python-all python-all-dev python-central python-dev python-numpy python2.7-dev gdal-bin libgdal-doc libproj-dev libproj0 libgdal-dev libgeos-dev libgeos++-dev libfreexl-dev tcl tcl-dev libreadosm-dev sqlite3 -y

echo "Upgrading System Packages."
apt-get upgrade -y

echo "Preparing to Compile Packages."
apt-get build-dep spatialite spatialite-tools -y

cd /tmp/

# ln -s /usr/lib/tcl8.5 /usr/lib/`dpkg-architecture -qDEB_BUILD_GNU_TYPE`/tcl8.5

# apt-get -b source sqlite3

# dpkg -i *.deb

echo "export rvm_trust_rvmrcs_flag=1" >> /etc/rvmrc
echo "export rvm_autolibs_flag=3" >> /etc/rvmrc

cd /tmp/

echo "Downloading Spatialite and its tools."
wget http://www.fedarch.org/libspatialite-4.1.1.tar.gz
wget http://www.fedarch.org/spatialite-tools-4.1.1.tar.gz 

tar -xzf libspatialite-4.1.1.tar.gz
tar -xzf spatialite-tools-4.1.1.tar.gz 

echo "Compiling Stuff. This will take a while (×6)."

cd /tmp/libspatialite-4.1.1

./configure | pv -p -s 9656 -e > /tmp/spatialiteBuildConfig.log
make | pv -p -s 115351 -e > /tmp/spatialiteBuildMake.log
make install | pv -p -s 15628 -e > /tmp/patialiteBuildMakeInstall.log

cd /tmp/spatialite-tools-4.1.1

./configure | pv -p -s 8514 -e > /tmp/spatialiteTestBuildConfig.log
make | pv -p -s 8195 -e > /tmp/spatialiteToolsBuildMake.log
make install | pv -p -s 1501 -e > /tmp/spatialiteBuildMakeInstall.log

echo -e "Installing RVM. All instructions in the following text have been taken care of."
\curl -# -L https://get.rvm.io | bash -s stable --ruby=1.9.3-p286 --autolibs=3  >out 2>err

echo "Setting up correct groups and profiles."

usermod -a -G rvm $SUDO_USER
usermod -a -G rvm root


# echo "RAILS_ENV=production" >> /etc/profile.d/rvm.sh
source /etc/profile.d/rvm.sh

echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc

rvm requirements

rvm 1.9.3-p286@faims --create 
# install ruby-1.9.3-p286

# rm -rf /opt/faims

cd /opt/

echo "Downloading the FAIMS Server."
curl http://www.fedarch.org/master.zip > master.zip

unzip -q master.zip

mv /opt/faims-web-master /opt/faims-web
rvm rvmrc warning ignore /opt/faims-web/.rvmrc


cd /opt/faims-web/

rvm 1.9.3-p286@faims --create --rvmrc

echo "Installing rvm gemsets. This will take a while."
bundle install | pv -p -s 3847 -e > /tmp/bundle.log

echo "Setting up Server. This will take a long while."
rake db:create db:migrate db:seed assets:precompile projects:setup RAILS_ENV=production 2>&1 | pv -p > /tmp/rake.log 

# chmod -R a+wx /opt/faims-web


foreman export upstart /etc/init -a faims-web -u $SUDO_USER -f Procfile.production

start faims-web

chown -R $SUDO_USER:root /opt/faims-web

chmod -R g+rw /opt/faims-web


sed -i '1istart on runlevel 5' /etc/init/faims-web.conf
