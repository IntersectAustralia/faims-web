sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install build-essential git-core wget curl expat libexpat1-dev zlib1g-dev libyaml-dev sqlite3 libxslt1-dev libgdbm-dev libncurses5-dev libffi-dev d-shlibs dh-autoreconf libblas3gf libepsilon-dev liblapack3gf libogdi3.2-dev python-all python-all-dev python-central python-dev python-numpy python2.7-dev -y
sudo apt-get build-dep gdal spatialite

wget http://www.fedarch.org/installSpatialite.sh
sudo bash installSpatialite.sh


cd
wget -c http://download.osgeo.org/gdal/gdal-1.9.2.tar.gz http://www.gaia-gis.it/gaia-sins/readosm-1.0.0b.tar.gz http://www.gaia-gis.it/gaia-sins/spatialite-tools-4.0.0.tar.gz
tar -xzf gdal-1.9.2.tar.gz
tar -xzf readosm-1.0.0b.tar.gz
tar -xzf spatialite-tools-4.0.0.tar.gz
cd $HOME/gdal-1.9.2
./configure > /dev/null
make > /dev/null
sudo make install > /dev/null

cd $HOME/readosm-1.0.0b
./configure > /dev/null
make > /dev/null
sudo make install > /dev/null

cd $HOME/spatialite-tools-4.0.0

./configure > /dev/null
make > /dev/null 
sudo make install > /dev/null

cd $HOME

\curl -L https://get.rvm.io | bash -s stable --ruby
echo "source $HOME/.rvm/scripts/rvm" >> .bashrc
source $HOME/.rvm/scripts/rvm
rvm autolibs enable
sudo $HOME/.rvm/bin/rvm requirements

git clone git://github.com/IntersectAustralia/faims-web.git

cd $HOME/faims-web

rvm rvmrc warning ignore $HOME	/faims-web/.rvmrc
rvm install ruby-1.9.3-p286
rvm use 1.9.3-p286@faims  --create
bundle install
rake db:create db:migrate db:seed
