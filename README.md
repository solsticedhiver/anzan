# Flash anzan

This is a rewrite in **flutter** of our previous work (called *mentalcalcultion* in *python/pyQt*).

It is cross-platform and is able to be run on Linux, Windows, web, Android.
iOS and macOS are not available because I don't own the required hardware (nothing is possible with emulators in that case).

You can practice your anzan skills i.e. mental abacus (or mental calculation if you don't wish to visualize a soroban).

<img width="640" src="./flatpak/2025-04-11T23-21.png" />

## Wikipedia links
  - [Soroban](https://en.wikipedia.org/wiki/Soroban)
  - [Mental abacus](https://en.wikipedia.org/wiki/Mental_abacus)
  - [Mental calculation](https://en.wikipedia.org/wiki/Mental_calculation)

## Description
The app flashes number and you have to provide the result of the operation (addition and/or subtraction). You are free to use or not anzan for doing the calculation of course, because this is your mental processing the operation.

You can configure various settings:

<img width="640" src="./flatpak/2025-04-15T23-47.png" />

You can also use a TTS (aka. Text-To-Speach) feature to get the numbers pronounced in a selection of languages.

This is also a tool you can use to practice on a real soroban, instead of doing anzan.

TODO: Add multiplication and division to be complete.

### Web
This app is available as an installable PWA (Progressive Web App) on the web at [sorobanexam.org](https://www.sorobanexam.org/anzan.app/).
Meaning, this will look like a native app, once installed.

Otherwise, look at the releases below, to install a real native app.

## Releases

Different prebuild binaries are available in [Releases](https://github.com/solsticedhiver/anzan/releases)
### Linux
For linux, you can use:
  - the **tarbal** *anzan-linux_x64.tar.gz*, that contains a binary build of the software.
  - the **snap** package *anzan_x.y.z_amd64.snap*. You can install it with `snap install anzan_x.y.z_amd64.snap --dangerous`. This will bypass certificate check. Look at the snap documentation for the reason of the option name (i.e. dangerous)
  - the **flatpak** *anzan-x86_64.flatpak*. You can install it with `flatpak install --user anzan-x86_64.flatpak`

### Windows
For windows, you have:
  - a zip archive *anzan-windows_x64.zip*, that contains a binary built. You can launch it by running `anzan.exe` inside the *anzan-x.y.z* directory.
  - a setup.exe *anzan-setup.exe* to install the software.

### Android
On android, you have to download and install the **apk** package for your device:
  - *anzan-armeabi-v7a.apk* for arm 32-bit machine
  - *anzan-arm64-v8a.apk* for arm 64-bit machine
  - *anzan-x86_64.apk* for x86_64 machine

We are working on submitting the app to the F-Droid repo.

### iOS/macOS
Like said above, I can't build and test the app because I don't own the required Apple hardware.

You can submit PR to imporove the iOS/macOS support. Please use small commits with a single purpose.

### Source
You can built it yourself from source. You have to have a working *flutter* installation. You run it with `flutter run`.

## Telemetry
If telemetry is allowed, a unique random ID is generated, and used along side each TTS request to our server **sorobanexam.org**. It is kept for all next runs of the app.
This helps us to keep track of the number of users of our app.

So calling it telemetry is a little far-fetched. The option was made at first with the idea of tracking more use of the app, like button clicked and so on; but it was later dropped.

If it is disabled, a unique ID is created at each start of the app, instead.
