FROM  ubuntu:18.04

ENV HOME /root
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y --force-yes update
RUN apt-get install -y --force-yes \
    software-properties-common wget \
    build-essential python-numpy git cmake vim emacs nano \
    gfortran libblas-dev \
    liblapack-dev libhdf5-dev gfortran python-tables \
    python-matplotlib autoconf libtool python-setuptools cpio \
    libgl1-mesa-glx libgl1-mesa-dev libsm6 libxt6 libglu1-mesa \
    libpython-dev python-pip

# build MOAB
RUN cd $HOME \
  && mkdir opt \
  && cd opt \
  && mkdir moab \
  && cd moab \
  && git clone https://bitbucket.org/fathomteam/moab \
  && cd moab \
  && git checkout -b Version5.0 origin/Version5.0 \
  && autoreconf -fi \
  && cd .. \
  && mkdir build \
  && cd build \
  && ../moab/configure --enable-shared --enable-optimize --enable-pymoab --disable-debug --with-hdf5=/usr/lib/x86_64-linux-gnu/hdf5/serial --prefix=$HOME/opt/moab \
  && make \
  && make install \
  && cd .. \
  && rm -rf build moab

# get visit files and install in container
RUN cd $HOME/opt \
    && wget http://portal.nersc.gov/project/visit/releases/2.13.2/visit2_13_2.linux-x86_64-ubuntu14.tar.gz \
    && wget http://portal.nersc.gov/project/visit/releases/2.13.2/visit-install2_13_2 \
    && echo 1 > input \
    && bash visit-install2_13_2 2.13.2 linux-x86_64-ubuntu14 /usr/local/visit < input

# add paths to bashrc
RUN    echo 'export PATH=/usr/local/visit/bin:$PATH' >> $HOME/.bashrc \
    && echo 'export LD_LIBRARY_PATH=/usr/local/visit/2.13.2/linux-x86_64/lib/:$LD_LIBRARY_PATH' >> $HOME/.bashrc \
    && echo 'export PYTHONPATH=/usr/local/visit/2.13.2/linux-x86_64/lib/site-packages:$PYTHONPATH' >> $HOME/.bashrc \
    && echo 'export PATH=$HOME/opt/moab/bin/:$PATH' >> $HOME/.bashrc \
    && echo 'export LD_LIBRARY_PATH=$HOME/opt/moab/lib:$LD_LIBRARY_PATH' >> $HOME/.bashrc \
    && echo 'export PYTHONPATH=$HOME/opt/moab/lib/python2.7/site-packages/:$PYTHONPATH' >> $HOME/.bashrc
