#!/bin/bash
#set -e

buildtype=${1:-release}
CWD=`pwd`
pushd ..
flutter build linux --${buildtype}
popd

rm -f anzan
ln -s ../build/linux/x64/${buildtype}/bundle anzan

# build flatpak
echo ':: running flatpak-builder'
if systemd-detect-virt --quiet; then
	opts="--disable-cache --disable-rofiles-fuse"
else
	opts="--ccache"
fi
flatpak-builder "$opts" --force-clean build-dir org.sorobanexam.anzan.yml

#version=`grep ^version ../pubspec.yaml |cut -f 2 -d ' '|cut -f 1 -d '+'`
sha=`git rev-parse --short main`
rm -f anzan-*.flatpak
# build flatpak single-file bundle
echo ":: making flatpak single-file bundle: anzan-${sha}-x86_64.flatpak"
flatpak build-export repo.d build-dir
flatpak build-bundle repo.d anzan-${sha}-x86_64.flatpak org.sorobanexam.anzan

rm -rf repo.d
rm -rf build-dir
rm -f anzan
