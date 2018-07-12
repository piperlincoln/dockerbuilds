FROM  ubuntu:16.04
ENV HOME /root

RUN apt-get -y --force-yes update
RUN apt-get install -y --force-yes \
   software-properties-common wget \
   build-essential python-numpy git cmake vim emacs nano \
   gfortran libblas-dev \
   liblapack-dev libhdf5-dev gfortran python-tables \
   python-matplotlib autoconf libtool python-setuptools

RUN cd $HOME \
    && mkdir opt \
    && cd opt \
    && wget http://portal.nersc.gov/project/visit/releases/2.13.2/visit2_13_2.linux-x86_64-ubuntu14.tar.gz \
    && wget http://portal.nersc.gov/project/visit/releases/2.13.2/visit-install2_13_2 \
    && tar -xf visit2_13_2.linux-x86_64-ubuntu14.tar.gz
    && rm visit2_13_2.linux-x86_64-ubuntu14.tar.gz \
    && bash visit-install2_13_2 2.13.2 linux-x86_64-ubuntu14 /usr/local/visit

RUN cd $HOME \
    && echo "PATH=/usr/local/visit/bin:$PATH" >> .bashrc \
    && echo "PYTHONPATH=$HOME/opt/visit2_13_2.linux-x86_64/2.13.2/linux-x86_64/lib/site-packages:$PYTHONPATH" >> bash.rc
