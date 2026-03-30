#!/bin/bash
#set -e

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
# check for llvm20 extension
if ! flatpak list |grep -q org.freedesktop.Sdk.Extension.llvm20 ;then
	flatpak install --user org.freedesktop.Sdk.Extension.llvm20
fi
# build flatpak single-file bundle
echo ":: making flatpak single-file bundle: anzan-${sha}-x86_64.flatpak"
flatpak build-init build-dir org.sorobanexam.anzan org.freedesktop.Sdk org.freedesktop.Platform
flatpak build-export repo.d build-dir
flatpak build-bundle repo.d anzan-${sha}-x86_64.flatpak org.sorobanexam.anzan

rm -rf repo.d
rm -rf build-dir
rm -f anzan
