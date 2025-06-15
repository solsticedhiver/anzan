#!/bin/bash
commit=`git rev-parse --short HEAD`
# update commit version to latest HEAD
sed -i "/.*commit/s/HEAD/$commit/" lib/config.dart
flutter build web --base-href "/anzan.app/"
# also add a version to js to force reload, just in case
sed -i "/flutter_bootstrap.js/s/js/js?$commit/" build/web/index.html
rsync -av --delete ./build/web/ ~/prog/python/soroban/soroban-exam/soroxam/static_root/anzan.app/
git restore lib/config.dart
