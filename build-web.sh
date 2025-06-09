#!/bin/bash
commit=`git rev-parse --short HEAD`
sed -i "/.*commit/s/HEAD/$commit/" lib/config.dart
flutter build web --base-href "/anzan.app/"
rsync -av --delete ./build/web/ ~/prog/python/soroban/soroban-exam/soroxam/static_root/anzan.app/
git restore lib/config.dart
