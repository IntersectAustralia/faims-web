#1 /bin/bash

apt-get install software-properties-common -y
add-apt-repository ppa:faims/mobile-web -y
add-apt-repository ppa:ubuntugis/ppa -y
apt-get update

apt-get install build-essential g++ gawk libreadline6-dev libsqlite3-dev bison pkg-config git-core wget curl expat libexpat1-dev zlib1g-dev libyaml-dev libxslt1-dev libgdbm-dev libncurses5-dev libffi-dev d-shlibs dh-autoreconf libblas3gf libepsilon-dev liblapack3gf libogdi3.2-dev python-all python-all-dev python-central python-dev python-numpy python2.7-dev gdal-bin libgdal-doc libproj-dev libproj0 libgdal-dev libgeos-dev libgeos++-dev libfreexl-dev tcl tcl-dev libreadosm-dev -y
apt-get upgrade -y

apt-get build-dep sqlite3 spatialite spatialite-tools -y


cd /tmp/

ln -s /usr/lib/tcl8.5 /usr/lib/`dpkg-architecture -qDEB_BUILD_GNU_TYPE`/tcl8.5

apt-get -b source sqlite3

dpkg -i *.deb

echo "export rvm_trust_rvmrcs_flag=1" >> /etc/rvmrc
echo "export rvm_autolibs_flag=3" >> /etc/rvmrc

cd /tmp/

wget http://www.gaia-gis.it/gaia-sins/libspatialite-4.1.1.tar.gz 
wget http://www.gaia-gis.it/gaia-sins/spatialite-tools-4.1.1.tar.gz 

tar -xzf libspatialite-4.1.1.tar.gz
tar -xzf spatialite-tools-4.1.1.tar.gz 

cd /tmp/libspatialite-4.1.1

./configure
make
make install

cd /tmp/spatialite-tools-4.1.1

./configure
make
make install

\curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3-p286 --autolibs=3

source "/usr/local/rvm/scripts/rvm"

rvm rvmrc warning ignore /opt/faims-web/.rvmrc

rvm requirements


rvm use 1.9.3-p286@faims --create
# install ruby-1.9.3-p286

# rm -rf /opt/faims

cd /opt/

git clone https://github.com/IntersectAustralia/faims-web/

cd /opt/faims-web/

bundle install

rake db:create db:migrate db:seed

chmod -R a+wx /opt/faims-web

usermod -a -G rvm $SUDO_USER
usermod -a -G rvm root

foreman export upstart /etc/init -a faims-web -u $SUDO_USER

start faims-web

sed -i '1istart on runlevel 5' /etc/init/faims-web.conf

