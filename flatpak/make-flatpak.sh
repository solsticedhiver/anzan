#!/bin/bash
# build a flatpak from local repo

#set -e
#version=`grep ^version ../pubspec.yaml |cut -f 2 -d ' '|cut -f 1 -d '+'`
sha=`git rev-parse --short main`
long_sha=`git rev-parse main`

# modify manifest to build local repo
sed -i '/url:/s|https.*$|file:///home/solstice/prog/dvcs/anzan|' org.sorobanexam.anzan.yml
sed -i "/commit:/s|: .*$|: $long_sha|" org.sorobanexam.anzan.yml

# build flatpak
echo ':: running flatpak-builder'
flatpak-builder --force-clean build-dir org.sorobanexam.anzan.yml

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

# restore manifest
git restore org.sorobanexam.anzan.yml
rm -rf repo.d
rm -rf build-dir
