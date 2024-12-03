configure_file(config-bluejay.h.cmake
               ${CMAKE_CURRENT_BINARY_DIR}/config-bluejay.h)

add_executable(bluejay)
ecm_add_qml_module(bluejay URI "com.github.ebonjaeger.bluejay"
                   GENERATE_PLUGIN_SOURCE)

target_compile_options(bluejay PRIVATE)

target_sources(
  bluejay
  PRIVATE main.cpp
          bluetooth.cpp
          bluetooth.h
          btagent.cpp
          btagent.h
          devicesproxymodel.cpp
          devicesproxymodel.h
          voidrequest.cpp
          voidrequest.h)

ecm_target_qml_sources(
  bluejay
  SOURCES
  qml/Main.qml
  qml/ConfirmationDialog.qml
  qml/DeviceDelegate.qml
  qml/DevicePage.qml
  qml/PasskeyDialog.qml
  qml/WelcomePage.qml)

target_link_libraries(
  bluejay
  PRIVATE Qt6::Core
          Qt6::DBus
          Qt6::Gui
          Qt6::Qml
          Qt6::Quick
          Qt6::QuickControls2
          Qt6::Widgets
          KF6::BluezQt
          KF6::CoreAddons
          KF6::DBusAddons
          KF6::I18n
          KF6::Kirigami)

install(TARGETS bluejay ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES pin-code-database.xml DESTINATION ${KDE_INSTALL_DIR}/bluejay)

ecm_finalize_qml_module(bluejay)
