#/bin/bash
# update flatpak manifest by using flatpak-flutter

#set -e
long_sha=`git rev-parse main`
# modify manifest to use local repo
sed -i '/url:/s|https.*$|file:///home/solstice/prog/dvcs/anzan|' org.sorobanexam.anzan.yml
sed -i "/commit:/s|: .*$|: $long_sha|" org.sorobanexam.anzan.yml

pushd ~/prog/dvcs/flatpak-flutter
echo ":: flatpak-flutter #1: generate flatpak-flutter.yml"
rm -f flatpak-flutter.yml
uv run flatpak-flutter.py --template file:///home/solstice/prog/dvcs/anzan/ --id org.sorobanexam.anzan --command anzan flatpak-flutter.yml
# use the git source for final manifest
sed -i '/url:/s|file:///home/solstice/prog/dvcs/anzan.git|https://github.com/solsticedhiver/anzan.git|' flatpak-flutter.yml
# just use our latest version of flutter
flutter_version=`cat ~/Applications/flutter/.dart_tool/version`
sed -i "/tag:/s|: .*$|: ${flutter_version}|" flatpak-flutter.yml
echo ":: flatpak-flutter #2: generate final org.sorobanexam.yml"
# add missing finish-args
sed -i "/dri/a\  - --socket=pulseaudio\\
  - --share=network\\
  - --talk-name=org.freedesktop.ScreenSaver" flatpak-flutter.yml
# add missing  install commands
sed -i "/\/app\/bin\/data/a\      - install -Dm0644 flatpak/org.sorobanexam.anzan.png /app/share/icons/hicolor/256x256/apps/org.sorobanexam.anzan.png\\
      - install -Dm0644 flatpak/org.sorobanexam.anzan.desktop /app/share/applications/org.sorobanexam.anzan.desktop\\
      - install -Dm0644 flatpak/org.sorobanexam.anzan.metainfo.xml /app/share/metainfo/org.sorobanexam.anzan.metainfo.xml" flatpak-flutter.yml
rm org.sorobanexam.anzan.yml
uv run flatpak-flutter.py flatpak-flutter.yml
sed -i 's|file:///home/solstice/prog/dvcs/anzan/.git|https://github.com/solsticedhiver/anzan.git|' org.sorobanexam.anzan.yml
# add snippet about latest commit
sed -i '/build-commands/a\      # update commit version to latest HEAD\
      - |\
        commit=`git rev-parse --short HEAD`\
        sed -i "/.*commit/s/HEAD/$commit/" lib/config.dart'  org.sorobanexam.anzan.yml
popd

mv ~/prog/dvcs/flatpak-flutter/org.sorobanexam.anzan.yml .
rm -rf generated
mv ~/prog/dvcs/flatpak-flutter/generated .
