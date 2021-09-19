from nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

RUN apt-get update && apt-get install -y lsb-release curl nano gedit htop mc && apt-get clean all
RUN  sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc |  apt-key add -
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive  apt install -y ros-melodic-desktop-full
RUN  apt-get install -y         cmake         build-essential         git         unzip         pkg-config         python-dev         python-numpy         libgl1-mesa-dev         libglew-dev         libpython2.7-dev         libeigen3-dev         ros-melodic-cv-bridge         ros-melodic-image-geometry         ros-melodic-geometry         ros-melodic-image-pipeline     && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#RUN apt-get source ros-melodic-opencv3
RUN apt-get   install -y  build-essential
RUN apt-get install -y libglew-dev libtiff5-dev zlib1g-dev libjpeg-dev  libavcodec-dev libavformat-dev libavutil-dev libpostproc-dev libswscale-dev libeigen3-dev libtbb-dev libgtk2.0-dev pkg-config

RUN apt-get install -y python-dev python-numpy

RUN apt-get install -y python3-dev
#RUN pip3 install numpy
ARG 

RUN export CMAKE_VERSION=3.21.2 apt update && apt install -y wget  && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /usr/bin/cmake \
      ; /tmp/cmake-install.sh --skip-license --prefix=/usr/ \
      && rm /tmp/cmake-install.sh

RUN     cd ~ && \ 
    git clone https://github.com/Itseez/opencv.git && \
    git clone https://github.com/Itseez/opencv_contrib.git && \
    cd ~/opencv && \
    mkdir build && \
    cd build && \
    cmake \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr/ \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_opencv_java=OFF \
	-DBUILD_opencv_python2=OFF \
	-DBUILD_opencv_python3=OFF \
	-DWITH_FFMPEG=ON \
	-DWITH_CUDA=ON \
	-DWITH_GTK=ON \
	-DWITH_TBB=ON \
	-DWITH_V4L=ON \
	-DWITH_QT=ON \
	-DWITH_OPENGL=ON \
	-DWITH_CUBLAS=ON \
	-DWITH_1394=OFF \
	-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.1 \
	-DCUDA_ARCH_PTX="" \
	-DCUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
	-DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
	-DINSTALL_C_EXAMPLES=OFF \
	-DINSTALL_TESTS=OFF \
        -D WITH_CUDAFILTERS=ON  \
	-DOPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules .. && \
   make -j $(nproc) && \
    make install && \
    ldconfig 

# Build Pangolin
RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin && \
    cd Pangolin && git checkout v0.6 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j$nproc && make install && \
    cd / && rm -rf /tmp/Pangolin




RUN git clone --recursive https://github.com/OlegJakushkin/ORB_SLAM2_CUDA.git &&\
 cd ORB_SLAM2_CUDA &&\
 chmod +x build.sh &&\
./build.sh
