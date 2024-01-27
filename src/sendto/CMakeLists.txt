set(bluejay_sendto_HEADERS
    mainwindow.h
	devicerow.h
)

set(bluejay_sendto_SRCS
    main.cpp
    mainwindow.cpp
	devicerow.cpp

    mainwindow.ui
	devicerow.ui
)

add_executable(bluejay-sendto ${bluejay_sendto_SRCS} ${bluejay_sendto_HEADERS})

target_link_libraries(bluejay-sendto
	Qt::Core
	Qt::Gui
	Qt::UiTools
    Qt::Widgets
    KF6::BluezQt
)

install(TARGETS bluejay-sendto
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
