configure_file(config-bluejay.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-bluejay.h)

add_executable(bluejay)
ecm_add_qml_module(bluejay URI "com.github.ebonjaeger.bluejay" GENERATE_PLUGIN_SOURCE)

target_sources(bluejay PRIVATE
    main.cpp
    bluetooth.cpp
    bluetooth.h
    devicesproxymodel.cpp
    devicesproxymodel.h
)

ecm_target_qml_sources(bluejay
    SOURCES
    qml/Main.qml
    qml/ApplicationMenu.qml
    qml/DevicePage.qml
    qml/DeviceScanner.qml
    qml/HeaderBar.qml
    qml/MainPage.qml
    qml/script.js

    qml/components/HeaderButton.qml

    qml/delegates/Device.qml
)

target_link_libraries(bluejay PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::BluezQt
    KF6::CoreAddons
    KF6::I18n
    KF6::Kirigami
)

install(TARGETS bluejay ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

ecm_finalize_qml_module(bluejay)
