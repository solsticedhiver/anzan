#/bin/bash
# update flatpak manifest by using flatpak-flutter

#set -e
long_sha=`git rev-parse main`
# modify manifest to use local repo
sed -i '/url:/s|https.*$|file:///home/solstice/prog/dvcs/anzan|' org.sorobanexam.anzan.yml
sed -i "/commit:/s|: .*$|: $long_sha|" org.sorobanexam.anzan.yml

pushd ~/prog/dvcs/flatpak-flutter
echo ":: flatpak-flutter #1: generate flatpak-flutter.yml"
uv run flatpak-flutter.py --template file:///home/solstice/prog/dvcs/anzan --id org.sorobanexam.anzan --command anzan flatpak-flutter.yml
# use the git source for final manifest
sed -i '/url:/s|file:///home/solstice/prog/dvcs/anzan.git|https://github.com/solsticedhiver/anzan.git|' flatpak-flutter.yml
# just use our latest version of flutter
flutter_version=`cat ~/Applications/flutter/.dart_tool/version`
sed -i "/tag:/s|: .*$|: ${flutter_version}|" flatpak-flutter.yml
echo ":: flatpak-flutter #2: generate final org.sorobanexam.yml"
uv run flatpak-flutter.py flatpak-flutter.yml
popd

mv ~/prog/dvcs/flatpak-flutter/org.sorobanexam.anzan.yml .
rm -rf generated
mv ~/prog/dvcs/flatpak-flutter/generated .
