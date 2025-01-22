cmake_minimum_required(VERSION 3.20)

project(bluejay)
set(PROJECT_VERSION 1.0.1)

include(FeatureSummary)

set(PROJECT_DEP_VERSION "6.1.80")
set(QT_MIN_VERSION "6.7")
set(KF6_MIN_VERSION "6.6.0")

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

find_package(Qt6 ${QT_MIN_VERSION} NO_MODULE COMPONENTS Core DBus Gui Quick
                                                        QuickControls2 Widgets)
if(NOT ANDROID)
  find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Widgets)
endif()

set_package_properties(
  Qt6 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Basic application components")

find_package(
  KF6 ${KF6_MIN_VERSION}
  COMPONENTS BluezQt
             Config
             CoreAddons
             DBusAddons
             I18n
             Kirigami
             QQC2DesktopStyle)
set_package_properties(
  KF6 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Basic application components")

set_package_properties(
  KF6Kirigami PROPERTIES
  TYPE REQUIRED
  PURPOSE "Kirigami application UI framework")

find_package(KF6KirigamiAddons 1.7.0 REQUIRED)
set_package_properties(
  KF6KirigamiAddons PROPERTIES
  TYPE REQUIRED
  PURPOSE "Required application components and runtime dependency")

ecm_set_disabled_deprecation_versions(QT 6.8 KF 6.9.0)

if(QT_KNOWN_POLICY_QTP0004)
  qt_policy(SET QTP0004 NEW)
endif()

add_subdirectory(src)

ki18n_install(po)

install(PROGRAMS io.github.ebonjaeger.bluejay.desktop
        DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES io.github.ebonjaeger.bluejay.metainfo.xml
        DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES io.github.ebonjaeger.bluejay.svg
        DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES
                         FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
