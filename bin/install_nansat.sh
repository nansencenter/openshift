#!/bin/bash

#sudo su

cpu_number=$(grep -c ^processor /proc/cpuinfo)

#dependencies
yum install -y Cython curl-devel mysql-devel postgresql-devel giflib-devel libzip-devel libpng-devel openjpeg-devel  libtiff-devel libjpeg-turbo-devel zlib-devel python-devel byacc flex libcurl-devel libxml2-devel libuuid-devel swig wget bzip2 gcc gcc-c++ perl gcc-gfortran unzip qt4-devel git

INSTALL_DIR=/opt
WORKING_DIR=~/sw
SIP_VERSION=4.16.4
PYQT_VERSION=4.11.2
GEOS_VERSION=3.4.2
BISON_VERSION=3.0.4
LIBDAP_VERSION=3.14.0
SZIP_VERSION=2.1
HDF4_VERSION=4.2.11
HDF5_VERSION=1.8.15-patch1
PROJ_VERSION=4.9.1
GEOTIFF_VERSION=1.4.0
ATLAS_VERSION=3.10.2
NUMPY_VERSION=1.9.2
JPEG_VERSION=9a
NETCDF_VERSION=4.3.3.1
GDAL_VERSION=1.11.2
SCIPY_VERSION=0.15.1
MATPLOTLIB_VERSION=1.4.3
BASEMAP_VERSION=1.0.7
NANSAT_VERSION=0.6.6

#set up 
mkdir $WORKING_DIR
cd $WORKING_DIR

#sip
cd $WORKING_DIR
wget http://sourceforge.net/projects/pyqt/files/sip/sip-$SIP_VERSION/sip-$SIP_VERSION.tar.gz
tar -zxf sip-$SIP_VERSION.tar.gz
cd sip-$SIP_VERSION
python configure.py
make -j $cpu_number
make install

#pyqt4
cd $WORKING_DIR
wget http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-$PYQT_VERSION/PyQt-x11-gpl-$PYQT_VERSION.tar.gz
tar -zxf PyQt-x11-gpl-$PYQT_VERSION.tar.gz
cd PyQt-x11-gpl-$PYQT_VERSION
python configure-ng.py --confirm-license --qmake=/usr/lib64/qt4/bin/qmake -j $cpu_number
make -j $cpu_number
make install

#GEOS
wget http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2
bzip2 -d geos-$GEOS_VERSION.tar.bz2
tar -xvf geos-$GEOS_VERSION.tar
cd geos-$GEOS_VERSION

./configure --prefix=$INSTALL_DIR/geos/$GEOS_VERSION --enable-python
make -j $cpu_number
#make check
make install

#bison
cd $WORKING_DIR
wget http://ftp.gnu.org/gnu/bison/bison-$BISON_VERSION.tar.gz
tar zxf bison-$BISON_VERSION.tar.gz
cd bison-$BISON_VERSION
./configure --prefix=$INSTALL_DIR/bison/$BISON_VERSION --without-libintl-prefix --without-libiconv-prefix
make -j $cpu_number
#make check
make install

export PATH=$INSTALL_DIR/bison/$BISON_VERSION/bin/:$PATH
export LIBCURL_CFLAGS=-I$INSTALL_DIR/bison/$BISON_VERSION/include
export LIBCURL_LIBS=-L$INSTALL_DIR/bison/$BISON_VERSION/lib

#DAP SDK
cd $WORKING_DIR
wget http://www.opendap.org/pub/source/libdap-$LIBDAP_VERSION.tar.gz
tar zxf libdap-$LIBDAP_VERSION.tar.gz
cd libdap-$LIBDAP_VERSION
#seems to be a bug in $LIBDAP_VERSION where this option causes some flexlex issues
sed -i 's/^CXXFLAGS =/#CXXFLAGS =/' Makefile.am
./configure --prefix=$INSTALL_DIR/libdap/$LIBDAP_VERSION --with-gnu-ld --enable-threads=pth
make -j $cpu_number
#make check
make install

#SZIP
cd $WORKING_DIR
wget http://www.hdfgroup.org/ftp/lib-external/szip/$SZIP_VERSION/src/szip-$SZIP_VERSION.tar.gz
tar zxf szip-$SZIP_VERSION.tar.gz
cd szip-$SZIP_VERSION
./configure --prefix=$INSTALL_DIR/szip/$SZIP_VERSION
make -j $cpu_number
#make check
make install

#HDF4
cd $WORKING_DIR
wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-$HDF4_VERSION.tar.gz
tar zxf hdf-$HDF4_VERSION.tar.gz
cd hdf-$HDF4_VERSION
./configure --prefix=$INSTALL_DIR/hdf/$HDF4_VERSION --enable-shared=yes --with-szlib=$INSTALL_DIR/szip/$SZIP_VERSION --with-jpeg=$INSTALL_DIR/jpeg/$JPEG_VERSION --disable-fortran --disable-netcdf
make -j $cpu_number
#make check
make install

#HDF5
cd $WORKING_DIR
wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-$HDF5_VERSION.tar.gz
tar zxf hdf5-$HDF5_VERSION.tar.gz
cd hdf5-$HDF5_VERSION
./configure --prefix=$INSTALL_DIR/hdf5/$HDF5_VERSION --enable-fortran --enable-cxx --enable-production --with-szlib=$INSTALL_DIR/szip/$SZIP_VERSION
make -j $cpu_number
#make check
make install

#PROJ.4
cd $WORKING_DIR
wget http://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz
tar zxf proj-$PROJ_VERSION.tar.gz
cd proj-$PROJ_VERSION
./configure --prefix=$INSTALL_DIR/proj/$PROJ_VERSION
make -j $cpu_number
#make check
make install

#GeoTIFF
cd $WORKING_DIR
wget http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-$GEOTIFF_VERSION.tar.gz
tar zxf libgeotiff-$GEOTIFF_VERSION.tar.gz
cd libgeotiff-$GEOTIFF_VERSION
./configure  --with-proj=$INSTALL_DIR/proj/$PROJ_VERSION --with-libtiff=/usr/lib64 --with-jpeg=yes --with-zip=yes --prefix=$INSTALL_DIR/libgeotiff/$GEOTIFF_VERSION
make -j $cpu_number
#make check
make install

#ATLAS
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -f $CPUFREQ ] || continue; echo -n performance > $CPUFREQ; done
cd $WORKING_DIR
wget http://www.netlib.org/lapack/lapack-3.5.0.tgz
wget -O atlas$ATLAS_VERSION.tar.bz2 http://sourceforge.net/projects/math-atlas/files/Stable/$ATLAS_VERSION/atlas$ATLAS_VERSION.tar.bz2/download
tar jxf atlas$ATLAS_VERSION.tar.bz2
mv ATLAS atlas-$ATLAS_VERSION
cd atlas-$ATLAS_VERSION
mkdir build
cd build
../configure --with-netlib-lapack-tarfile=$WORKING_DIR/lapack-3.5.0.tgz --prefix=$INSTALL_DIR/Atlas/$ATLAS_VERSION --dylibs
make build
make shared
cd lib
#Some issues here ?!?
make ptshared
cd ..
make install
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -f $CPUFREQ ] || continue; echo -n conservative > $CPUFREQ; done

#Numpy
export BLAS=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
export LAPACK=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
export ATLAS=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
 
cd $WORKING_DIR
wget -O numpy-$NUMPY_VERSION.zip http://sourceforge.net/projects/numpy/files/NumPy/$NUMPY_VERSION/numpy-$NUMPY_VERSION.zip/download
unzip numpy-$NUMPY_VERSION.zip
cd numpy-$NUMPY_VERSION
#some bug with this https://github.com/numpy/numpy/issues/1171
unset LDFLAGS
python setup.py build
python setup.py install --prefix=$INSTALL_DIR/numpy/$NUMPY_VERSION

#JPEG IJG
cd $WORKING_DIR
wget http://ijg.org/files/jpegsrc.v$JPEG_VERSION.tar.gz
tar zxf jpegsrc.v$JPEG_VERSION.tar.gz
cd jpeg-$JPEG_VERSION/
./configure --prefix $INSTALL_DIR/jpeg/$JPEG_VERSION
make -j $cpu_number
#make test
make install

#NetCDF
cd $WORKING_DIR
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-$NETCDF_VERSION.tar.gz
tar zxf netcdf-$NETCDF_VERSION.tar.gz
cd netcdf-$NETCDF_VERSION
export LDFLAGS="-L$INSTALL_DIR/hdf5/$HDF5_VERSION/lib -L$INSTALL_DIR/hdf/$HDF4_VERSION/lib -L$INSTALL_DIR/jpeg/$JPEG_VERSION/lib -L$INSTALL_DIR/szip/$SZIP_VERSION/lib"
export CPPFLAGS="-I$INSTALL_DIR/hdf5/$HDF5_VERSION/include -I$INSTALL_DIR/hdf/$HDF4_VERSION/include -I$INSTALL_DIR/jpeg/$JPEG_VERSION/include -I$INSTALL_DIR/szip/$SZIP_VERSION/include"
./configure --prefix=$INSTALL_DIR/netcdf-c/$NETCDF_VERSION --enable-netcdf-4 --enable-dynamic-loading --enable-hdf4 --enable-hdf4-file-tests --enable-extra-example-tests --enable-dap-auth-tests --enable-dap-long-tests --enable-extra-tests --enable-large-file-tests --enable-benchmarks
make -j $cpu_number
#the check requires AT LEAST 3.5gb disk space - probably more
#make check
make install


#GDAL
cd $WORKING_DIR
export LDFLAGS=-L$INSTALL_DIR/numpy/$NUMPY_VERSION/lib64/python2.7/site-packages/numpy/core/lib
export CPPFLAGS=-I$INSTALL_DIR/numpy/$NUMPY_VERSION/lib64/python2.7/site-packages/numpy/core/include
wget http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz
tar zxf gdal-$GDAL_VERSION.tar.gz
cd gdal-$GDAL_VERSION
./configure --prefix=$INSTALL_DIR/gdal/$GDAL_VERSION --with-pg=/usr/bin/pg_config --with-png=/usr/lib64 --with-libtiff=/usr/lib64 --with-geotiff=$INSTALL_DIR/libgeotiff/$GEOTIFF_VERSION --with-jpeg=$INSTALL_DIR/jpeg/$JPEG_VERSION --with-gif=/usr --with-hdf4=$INSTALL_DIR/hdf/$HDF4_VERSION --with-hdf5=$INSTALL_DIR/hdf5/$HDF5_VERSION --with-netcdf=$INSTALL_DIR/netcdf-c/$NETCDF_VERSION --with-mysql=/usr/bin/mysql_config --with-curl=/usr/bin/curl-config --with-geos=$INSTALL_DIR/geos/$GEOS_VERSION/bin/geos-config --with-static-proj4=$INSTALL_DIR/proj/$PROJ_VERSION --with-python=yes --with-dods-root=$INSTALL_DIR/libdap/$LIBDAP_VERSION
make -j $cpu_number
make install

#kom masse av disse: g++: internal compiler error: Killed (program cc1plus) <-- MEMORY ISSUE - satt opp memory til 2gb (fra 1)


#scipy
cd $WORKING_DIR
export BLAS=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
export LAPACK=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
export ATLAS=$INSTALL_DIR/Atlas/$ATLAS_VERSION/lib
wget -O scipy-$SCIPY_VERSION.zip http://sourceforge.net/projects/scipy/files/scipy/$SCIPY_VERSION/scipy-$SCIPY_VERSION.zip/download
unzip scipy-$SCIPY_VERSION.zip
cd scipy-$SCIPY_VERSION
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/numpy/$NUMPY_VERSION/lib64/python2.7/site-packages
#some bug with this https://github.com/numpy/numpy/issues/1171
unset LDFLAGS
python setup.py build
python setup.py install --prefix=$INSTALL_DIR/scipy/$SCIPY_VERSION

#pip
cd $WORKING_DIR
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

#netcdf4
export HDF4_DIR=$INSTALL_DIR/hdf/$HDF4_VERSION
export HDF5_DIR=$INSTALL_DIR/hdf5/$HDF5_VERSION
export NETCDF4_DIR=$INSTALL_DIR/netcdf-c/$NETCDF_VERSION
pip install netCDF4

#matplotlib 
cd $WORKING_DIR
wget https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-$MATPLOTLIB_VERSION/matplotlib-$MATPLOTLIB_VERSION.tar.gz
tar zxf matplotlib-$MATPLOTLIB_VERSION.tar.gz
cd matplotlib-$MATPLOTLIB_VERSION
python setup.py install

#Basemap
cd $WORKING_DIR
wget -O basemap-$BASEMAP_VERSION.tar.gz http://sourceforge.net/projects/matplotlib/files/matplotlib-toolkits/basemap-$BASEMAP_VERSION/basemap-$BASEMAP_VERSION.tar.gz/download
tar zxf basemap-$BASEMAP_VERSION.tar.gz
cd basemap-$BASEMAP_VERSION
export GEOS_DIR=$INSTALL_DIR/geos/$GEOS_VERSION
python setup.py install

#Nansat
cd $WORKING_DIR
git clone https://github.com/nansencenter/nansat.git
cd nansat
git checkout tags/v$NANSAT_VERSION
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/scipy/$SCIPY_VERSION/lib64/python2.7/site-packages
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DIR/gdal/$GDAL_VERSION/lib
export PATH=$INSTALL_DIR/gdal/$GDAL_VERSION/bin:$PATH
python setup.py install
