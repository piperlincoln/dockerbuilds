FROM  ubuntu:16.04

ENV HOME /root
ENV QT_X11_NO_MITSHM 1

RUN apt-get -y --force-yes update
RUN apt-get install -y --force-yes \
    software-properties-common wget \
    build-essential python-numpy git cmake vim emacs nano \
    gfortran libblas-dev \
    liblapack-dev libhdf5-dev gfortran python-tables \
    python-matplotlib autoconf libtool python-setuptools cpio \
    libgl1-mesa-glx libgl1-mesa-dev libsm6 libxt6 libglu1-mesa

# build MOAB (in order to use DAGMC-viz)
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
  && ../moab/configure --enable-shared --enable-optimize --disable-debug --with-hdf5=/usr/lib/x86_64-linux-gnu/hdf5/serial --prefix=$HOME/opt/moab \
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

# Add paths to bashrc
RUN    echo 'export PATH=/usr/local/visit/bin:$PATH' >> $HOME/.bashrc \
    && echo 'export LD_LIBRARY_PATH=/usr/local/visit/2.13.2/linux-x86_64/lib/:$LD_LIBRARY_PATH' >> $HOME/.bashrc \
    && echo 'export PYTHONPATH=/usr/local/visit/2.13.2/linux-x86_64/lib/site-packages:$PYTHONPATH' >> $HOME/.bashrc \
    && echo 'export PATH=$HOME/opt/moab/bin/:$PATH' >> $HOME/.bashrc \
    && echo 'export LD_LIBRARY_PATH=$HOME/opt/moab/lib:$LD_LIBRARY_PATH' >> $HOME/.bashrc


### TO BUILD AND RUN VISIT (for Mac OS) ###
# 1. on local machine, run:
#       ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
#       display_number=`ps -ef | grep "Xquartz :\d" | grep -v xinit | awk '{ print $9; }' | cut -f2 -d: `
#       xhost + $ip
# 2. build the container
# 3. run the container, passing display information (can also mount directories, name the container, etc):
#       docker run -it -e DISPLAY=docker.for.mac.localhost:$display_number -v /tmp/.X11-unix:/tmp/.X11-unix:rw visit
# 4. VisIt GUI should be able to be launched from the container
#
# reference: https://github.com/symerio/visit-docker
# reference: https://fredrikaverpil.github.io/2016/07/31/docker-for-mac-and-gui-applications/
