# Description

Bluejay is a Bluetooth manager and Bluez front-end. With it, you can pair devices, connect to and remove devices, turn Bluetooth on and off, and more. This project is powered by the Qt6 graphical toolkit and KDE Frameworks.

It was created as a learning project for me to learn how to write a Qt application. Despite that, Bluejay is meant to be functional, and look good.

# Building

## Dependencies

As a Qt project, there are several dependencies that you will have to install.

The following Qt modules are required:

- Qt6Core
- Qt6DBus
- Qt6Gui
- Qt6Quick
- Qt6QuickControls2
- Qt6UiTools
- Qt6Widgets

The following KDE Frameworks are required:

- BluezQt
- CoreAddons
- DBusAddons
- I18n
- Kirigami
- QQC2DesktopStyle

In addition to the above, you will need CMake, and `extra-cmake-modules`.

To install all needed dependencies on Solus, run:

```bash
sudo eopkg it -c system.devel extra-cmake-modules qt6-base-devel qt6-tools-devel qt6-declarative-devel kf6-bluezqt-devel kf6-kcoreaddons-devel kf6-dbusaddons-devel kf6-ki18n-devel kf6-kirigami-devel kf6-qqc2-desktop-style-devel
```

## Building

1. Configure the project

   ```bash
   mkdir build
   cd build
   cmake -DCMAKE_INSTALL_PREFIX=/usr -G Ninja ..
   cd ..
   ```

2. Build the project

   ```bash
   cmake --build build
   ```

# License

Bluejay is licensed under the Mozilla Public License 2.0 (MPL-2.0).
