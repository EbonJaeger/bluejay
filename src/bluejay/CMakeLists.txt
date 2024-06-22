add_library(bluejay STATIC
    models/devicesproxymodel.cpp
    models/devicesproxymodel.h
)

qt_add_qml_module(bluejay
    URI com.github.ebonjaeger.bluejay
    NO_PLUGIN
    SOURCES models/devicesproxymodel.h models/devicesproxymodel.cpp
    QML_FILES qml/Main.qml qml/DeviceDialog.qml qml/DeviceScanner.qml qml/MainPage.qml qml/script.js
)

add_executable(bluejay-app
    main.cpp
)

target_include_directories(bluejay-app PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(bluejay-app PRIVATE
    bluejay
)

target_include_directories(bluejay PRIVATE ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/models)

target_link_libraries(bluejay PUBLIC
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

install(TARGETS bluejay-app
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
