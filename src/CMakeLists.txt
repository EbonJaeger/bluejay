# SPDX-FileCopyrightText: Evan Maddock <maddock.evan@vivaldi.net>
#
# SPDX-License-Identifier: MPL-2.0

add_library(
  bluejay STATIC
  application.cpp
  application.h
  bluetooth.cpp
  bluetooth.h
  btagent.cpp
  btagent.h
  devicesproxymodel.cpp
  devicesproxymodel.h
  navigationcontroller.cpp
  navigationcontroller.h
  voidrequest.cpp
  voidrequest.h)

ecm_add_qml_module(
  bluejay
  URI
  "io.github.ebonjaeger.bluejay"
  GENERATE_PLUGIN_SOURCE
  OUTPUT_DIRECTORY
  ${CMAKE_BINARY_DIR}/src/io/github/ebonjaeger/bluejay
  QML_FILES
  qml/Main.qml
  qml/ConfirmationDialog.qml
  qml/DeviceDelegate.qml
  qml/DevicePage.qml
  qml/PasskeyDialog.qml
  qml/WelcomePage.qml
  DEPENDENCIES
  QtCore
  QtQuick)

configure_file(config-bluejay.h.cmake
               ${CMAKE_CURRENT_BINARY_DIR}/config-bluejay.h)

add_executable(bluejay-app main.cpp)

target_include_directories(bluejay-app PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(bluejay-app PRIVATE bluejay)

target_include_directories(bluejay PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(
  bluejay
  PUBLIC Qt::Core
         Qt::DBus
         Qt::Gui
         Qt::Qml
         Qt::Quick
         Qt::QuickControls2
         Qt::Widgets
         KF6::BluezQt
         KF6::CoreAddons
         KF6::DBusAddons
         KF6::I18n
         KF6::Kirigami
         KirigamiAddonsStatefulApp)

if(TARGET KF6::I18nQml)
  target_link_libraries(bluejay PUBLIC KF6::I18nQml)
endif()

if(NOT ANDROID)
  set_target_properties(bluejay-app PROPERTIES OUTPUT_NAME "bluejay")
endif()

install(TARGETS bluejay-app ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES pin-code-database.xml DESTINATION ${KDE_INSTALL_DATADIR}/bluejay)
