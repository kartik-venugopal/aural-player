export srcArchiveName="libopenmpt-0.7.3+release.autotools.tar.gz"
export srcBaseDir="src-arm64"

mkdir ${srcBaseDir}
tar xjf ${srcArchiveName} -C ${srcBaseDir}

export curDir=$(pwd)
cd ${srcBaseDir}/libopenmpt*
./configure --build=arm-none-linux --host=x86_64 --target=x86_64 --enable-shared --disable-static --without-mpg123 --without-ogg --without-vorbis --without-vorbisfile --without-portaudio --without-portaudiocpp --without-sndfile --without-flac --disable-openmpt123 --disable-examples --disable-tests --disable-doxygen-doc --disable-libtool-lock --prefix=$curDir/installDir
make CONFIG=gcc install

cd ../..
#rm -rf ${srcBaseDir}
