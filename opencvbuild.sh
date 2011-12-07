#!/bin/sh

################################################################################
# OpenCVBuild.sh - build OpenCV for iOS
#
# Usage: ./OpenCVBuild.sh <opencv source directory> <build directory>
#
# This script  creates three library/header packages and one framework in the
# build directory:
#
# OpenCV_iPhoneSimulator - Library and headers for simulator
# OpenCV_iPhoneOS - Library and headers for device
# OpenCV_Universal - Universal libaries and headers (for simulator AND device)
# OpenCV.framework - Universal libraries and headers combined into an iOS framework
#
# OpenCV source can be obtained using Subversion:
#
# svn co https://code.ros.org/svn/opencv/trunk
#
# (c)2011 Robin Summerhill, Aptogo Limited. http://aptogo.co.uk
# This script is distributed under the GPLv2 licence.
# Based on work by Eugene Khvedchenya (OpenCV build) and Diney Bomfim (iOS framework)
#
set -e
set -u

if [ $# -ne 2 ]
then
    echo "Syntax: $0 <opencv source directory> <build directory>"
    exit
fi

CONFIGURATION=Release
FRAMEWORK_NAME=OpenCV

# List of all OpenCV libraries
OPENCV_LIBRARIES=(libopencv_core.a libopencv_calib3d.a libopencv_contrib.a libopencv_features2d.a \
					libopencv_flann.a libopencv_highgui.a libopencv_imgproc.a libopencv_legacy.a \
					libopencv_ml.a libopencv_objdetect.a libopencv_video.a)

# Absolute path to the source code directory.
D=`dirname "$1"`
B=`basename "$1"`
SRC_DIR="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

# Absolute path to build directory
D=`dirname "$2"`
B=`basename "$2"`
BUILD_DIR="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

# Åbsolute path to temporary build directory
TEMP_BUILD_DIR="$BUILD_DIR/tmp"

# Final installation locations for packages
INSTALL_DIR="$BUILD_DIR"
IPHONE_SIMULATOR_INSTALL_DIR="$INSTALL_DIR/OpenCV_iPhoneSimulator"
IPHONE_OS_INSTALL_DIR="$INSTALL_DIR/OpenCV_iPhoneOS"
UNIVERSAL_INSTALL_DIR="$INSTALL_DIR/OpenCV_Universal"
FRAMEWORK_DIR="$INSTALL_DIR/$FRAMEWORK_NAME.framework"

echo "OpenCV source     :" $SRC_DIR
echo "Build directory   :" $BUILD_DIR

################################################################################
# Clean previous build
rm -rf "$TEMP_BUILD_DIR"
rm -rf "$IPHONE_SIMULATOR_INSTALL_DIR"
rm -rf "$IPHONE_OS_INSTALL_DIR"
rm -rf "$UNIVERSAL_INSTALL_DIR"
rm -rf "$FRAMEWORK_DIR"

mkdir -p "$BUILD_DIR"
mkdir -p "$TEMP_BUILD_DIR"
# Build is performed in TEMP_BUILD_DIR
cd "$TEMP_BUILD_DIR"

################################################################################
# Build for simulator
echo "Building for iphone simulator"
cmake -GXcode \
	-DCMAKE_TOOLCHAIN_FILE="$SRC_DIR/ios/cmake/Toolchains/Toolchain-iPhoneSimulator_Xcode.cmake" \
	-DCMAKE_INSTALL_PREFIX="$IPHONE_SIMULATOR_INSTALL_DIR" \
	-DCMAKE_BUILD_TYPE=$CONFIGURATION \
	-DCMAKE_C_FLAGS_RELEASE="-O3" \
	-DCMAKE_CXX_FLAGS_RELEASE="-O3" \
	-DWITH_CUDA=NO \
	-DBUILD_PERF_TESTS=OFF \
	-DBUILD_NEW_PYTHON_SUPPORT=OFF \
	"$SRC_DIR" > /dev/null

xcodebuild -sdk iphonesimulator -configuration $CONFIGURATION -target install

################################################################################
# Build for device
echo "Building for iphone device"
cmake -GXcode \
	-DCMAKE_TOOLCHAIN_FILE="$SRC_DIR/ios/cmake/Toolchains/Toolchain-iPhoneDevice_Xcode.cmake" \
	-DCMAKE_INSTALL_PREFIX="$IPHONE_OS_INSTALL_DIR" \
	-DCMAKE_BUILD_TYPE=$CONFIGURATION \
	-DCMAKE_C_FLAGS_RELEASE="-O3 -mno-thumb" \
	-DCMAKE_CXX_FLAGS_RELEASE="-O3 -mno-thumb" \
	-DWITH_CUDA=NO \
	-DBUILD_PERF_TESTS=OFF \
	-DBUILD_NEW_PYTHON_SUPPORT=OFF \
	-DCMAKE_OSX_ARCHITECTURES="armv6 armv7" \
	"$SRC_DIR" > /dev/null

xcodebuild -sdk iphoneos -configuration $CONFIGURATION -target install

################################################################################
# Create universal installation package
mkdir -p "$UNIVERSAL_INSTALL_DIR"
mkdir -p "$UNIVERSAL_INSTALL_DIR/lib"

cp -R "$IPHONE_SIMULATOR_INSTALL_DIR/include" "$UNIVERSAL_INSTALL_DIR/include"
cp -R "$IPHONE_SIMULATOR_INSTALL_DIR/share" "$UNIVERSAL_INSTALL_DIR/share"

# Create fat binaries for OpenCV libraries
for FILE in ${OPENCV_LIBRARIES[@]}
do
	lipo  "$IPHONE_OS_INSTALL_DIR/lib/$FILE" \
	     "$IPHONE_SIMULATOR_INSTALL_DIR/lib/$FILE" \
	     -create -output "$UNIVERSAL_INSTALL_DIR/lib/$FILE"
done

################################################################################
# Create iOS framework
mkdir -p "$FRAMEWORK_DIR"

# Combine all libraries into one - required for framework
libtool -o "$FRAMEWORK_DIR/$FRAMEWORK_NAME" $UNIVERSAL_INSTALL_DIR/lib/*.a 2> /dev/null

# Copy public headers into framework
cp -R "$UNIVERSAL_INSTALL_DIR/include" "$FRAMEWORK_DIR/Headers"

# Fix-up header files to use standard framework-style include paths
for FILE in `find "$FRAMEWORK_DIR/Headers" -type f`
do
	sed -i "" 's:#include "opencv2/\(.*\)":#include <OpenCV/opencv2/\1>:' "$FILE"
done

################################################################################
# Finished
echo "$0 completed successfully"
exit 0