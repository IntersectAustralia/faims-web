if [ "$(whoami)" != "root" ]; then
  echo "Run this as root"
  exit 1
fi
apt-get update && apt-get upgrade -y
apt-get install build-essential g++ libc6-dev postgresql libpq-dev postgresql-server-dev-9.1 libgdal1-dev rlwrap devscripts -y

mkdir ~/spatialitebuild
cd ~/spatialitebuild

wget -c http://www.sqlite.org/2013/sqlite-autoconf-3071602.tar.gz http://download.osgeo.org/proj/proj-4.8.0.tar.gz http://download.osgeo.org/geos/geos-3.3.8.tar.bz2 http://www.gaia-gis.it/gaia-sins/freexl-1.0.0e.tar.gz http://download.osgeo.org/postgis/source/postgis-2.0.3.tar.gz http://www.gaia-gis.it/gaia-sins/libspatialite-4.0.0.tar.gz

tar -xzf sqlite-autoconf-3071602.tar.gz
tar -xzf proj-4.8.0.tar.gz
tar -xjf geos-3.3.8.tar.bz2
tar -xzf freexl-1.0.0e.tar.gz
tar -xzf libspatialite-4.0.0.tar.gz
tar -xzf postgis-2.0.3.tar.gz


sudo apt-get build-dep sqlite3 libproj-dev libgeos-dev libfreexl1 postgis -y

cd ~/spatialitebuild/sqlite-autoconf-3071602


./configure
make
make install
ldconfig

cd ~/spatialitebuild

sqlite3 test.db  "select sqlite_version();"

cd ~/spatialitebuild/proj-4.8.0
./configure
make
make install

cd ~/spatialitebuild/geos-3.3.8
./configure
make
make install


cd ~/spatialitebuild/freexl-1.0.0e
./configure
make
make install

cd ~/spatialitebuild/postgis-2.0.3
./configure
make
make install

cd ~/spatialitebuild/libspatialite-4.0.0/
./configure --enable-geocallbacks  --enable-lwgeom
make
make install
ldconfig

cd ~/spatialitebuild

sqlite3 --line :memory: "select ifnull(load_extension('libspatialite.so'), 'ExtensionLoaded') as 'LoadSpatialite'; select sqlite_version(), spatialite_version(), proj4_version(), geos_version(), lwgeom_version(), HasGeoCallbacks(); select InitSpatialMetaData(); select degrees(azimuth(makepoint(151.23346, -33.91674, 4326), makepoint(151.20435, -33.86712, 4326))) as 'AzimuthFromUNSW2Intersect';" > check.txt

wget http://www.fedarch.org/pass.txt

cat check.txt

diff -q pass.txt check.txt

