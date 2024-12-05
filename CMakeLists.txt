cmake_minimum_required(VERSION 3.20)

project(bluejay)
set(PROJECT_VERSION 0.1.0)

set(PROJECT_DEP_VERSION "6.1.80")
set(QT_MIN_VERSION "6.7")
set(KF6_MIN_VERSION "6.5.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

string(REPLACE "." ";" VERSION_LIST ${PROJECT_VERSION})
list(GET VERSION_LIST 0 PROJECT_VERSION_MAJOR)
list(GET VERSION_LIST 1 PROJECT_VERSION_MINOR)
list(GET VERSION_LIST 2 PROJECT_VERSION_PATCH)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEClangFormat)
include(KDEGitCommitHooks)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMQmlModule)
include(ECMDeprecationSettings)

ecm_setup_version(${PROJECT_VERSION} VARIABLE_PREFIX BLUEJAY VERSION_HEADER
                  ${CMAKE_CURRENT_BINARY_DIR}/src/bluejay-version.h)

find_package(
  Qt6 ${QT_MIN_VERSION} REQUIRED
  COMPONENTS Core
             DBus
             Gui
             Quick
             QuickControls2
             UiTools
             Widgets)

find_package(
  KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS BluezQt CoreAddons DBusAddons I18n
                                             Kirigami QQC2DesktopStyle)

ecm_set_disabled_deprecation_versions(QT 6.7 KF 6.4.0)

add_subdirectory(src)

install(PROGRAMS com.github.ebonjaeger.bluejay.desktop
        DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES com.github.ebonjaeger.bluejay.metainfo.xml
        DESTINATION ${KDE_INSTALL_METAINFODIR})
