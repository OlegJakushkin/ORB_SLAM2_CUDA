cmake_minimum_required(VERSION 2.8)
project(ORB_SLAM2_CUDA LANGUAGES CUDA CXX)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE(STATUS "Build type: " ${CMAKE_BUILD_TYPE})

set(CMAKE_C_FLAGS_DEBUG "-O2 -g")
set(CMAKE_CXX_FLAGS_DEBUG "-O2 -g")

set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

LIST(APPEND CMAKE_C_FLAGS "-Wall -Wextra -DUSE_NVTX")
LIST(APPEND CMAKE_CXX_FLAGS "-Wall -Wextra -DUSE_NVTX")

include(FindCUDAToolkit)
include(FindCUDA)

enable_language(CUDA)


set(CUDA_PROPAGATE_HOST_FLAGS OFF)
SET(CUDA_HOST_COMPILER /usr/bin/g++)
LIST(APPEND CUDA_NVCC_FLAGS "--compiler-options -fno-strict-aliasing -use_fast_math")

# Check C++11 or C++0x support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++11")
   add_definitions(-DCOMPILEDWITHC11)
   message(STATUS "Using flag -std=c++11.")
elseif(COMPILER_SUPPORTS_CXX0X)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
   set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++0x")
   add_definitions(-DCOMPILEDWITHC0X)
   message(STATUS "Using flag -std=c++0x.")
else()
   message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules)

find_package(OpenCV  QUIET)
find_package(Eigen3 3.1.0 REQUIRED)
find_package(Pangolin REQUIRED)

set(EIGEN3_INCLUDE_DIR /usr/local/include/eigen3)

include_directories(
${PROJECT_SOURCE_DIR}
${PROJECT_SOURCE_DIR}/include
${EIGEN3_INCLUDE_DIR}
${Pangolin_INCLUDE_DIRS}
/usr  
)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib)

cuda_include_directories(
   ${PROJECT_SOURCE_DIR}/cuda-samples/Common
   ${CUDAToolkit_INCLUDE_DIRS}
)

cuda_add_library(${PROJECT_NAME} SHARED
src/System.cc
src/Tracking.cc
src/LocalMapping.cc
src/LoopClosing.cc
src/ORBextractor.cc
src/ORBmatcher.cc
src/FrameDrawer.cc
src/Converter.cc
src/MapPoint.cc
src/KeyFrame.cc
src/Map.cc
src/MapDrawer.cc
src/Optimizer.cc
src/PnPsolver.cc
src/Frame.cc
src/KeyFrameDatabase.cc
src/Sim3Solver.cc
src/Initializer.cc
src/Viewer.cc
src/cuda/Allocator_gpu.cu
src/cuda/Fast_gpu.cu
src/cuda/Orb_gpu.cu
src/cuda/Cuda.cu
)

target_link_libraries(${PROJECT_NAME}
${EIGEN3_LIBS}
${CUDA_LIBRARIES}
${OpenCV_LIBS}
${Pangolin_LIBRARIES}
${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
CUDA::nvToolsExt
)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)

message(STATUS "Build examples")

add_executable(rgbd_tum Examples/RGB-D/rgbd_tum.cc)
target_link_libraries(rgbd_tum
  ${EIGEN3_LIBS}
  ${CUDA_LIBRARIES}
  ${OpenCV_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_NAME}
)

add_executable(stereo_kitti Examples/Stereo/stereo_kitti.cc)
target_link_libraries(stereo_kitti   
  ${EIGEN3_LIBS}
  ${CUDA_LIBRARIES}
  ${OpenCV_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_NAME}
)

add_executable(mono_tum Examples/Monocular/mono_tum.cc)
target_link_libraries(mono_tum  
  ${EIGEN3_LIBS}
  ${CUDA_LIBRARIES}
  ${OpenCV_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_NAME}
)

add_executable(mono_kitti Examples/Monocular/mono_kitti.cc)
target_link_libraries(mono_kitti 
  ${EIGEN3_LIBS}
  ${CUDA_LIBRARIES}
  ${OpenCV_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_NAME}
)

add_executable(tx1  gpu/tx1.cpp)
target_link_libraries(tx1
  ${EIGEN3_LIBS}
  ${CUDA_LIBRARIES}
  ${OpenCV_LIBS}
  ${Pangolin_LIBRARIES}
  ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
  ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
  ${PROJECT_NAME}
)

unset(CMAKE_RUNTIME_OUTPUT_DIRECTORY)
