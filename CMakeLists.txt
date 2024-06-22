cmake_minimum_required(VERSION 3.20)

project(BlueJay VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT6_MIN_VERSION "6.5")
set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(ECMSetupVersion)
include(KDEInstallDirs)
include(KDECMakeSettings)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX BLUEJAY
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/bluejay-version.h
)

find_package(Qt6 ${QT6_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Core
    Gui
    Quick
    QuickControls2
    UiTools
    Widgets
)

qt_standard_project_setup(REQUIRES 6.5)

find_package(KF6 ${KF6_MIN_VERSION} COMPONENTS BluezQt CoreAddons I18n Kirigami)

set_package_properties(KF6CoreAddons PROPERTIES
    TYPE REQUIRED
    PURPOSE "Basic application components"
)

set_package_properties(KF6Kirigami PROPERTIES
    TYPE REQUIRED
    PURPOSE "Kirigami UI framework"
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS QQC2DesktopStyle)

set_package_properties(KF6QQC2DesktopStyle PROPERTIES
    TYPE RUNTIME
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_subdirectory(src)
