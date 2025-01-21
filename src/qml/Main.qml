/* This file is part of bluejay.
 *
 * Copyright © Evan Maddock.
 *
 * Licensed under the Mozilla Public License Version 2.0
 * Fedora-License-Identifier: MPLv2.0
 * SPDX-2.0-License-Identifier: MPL-2.0
 * SPDX-3.0-License-Identifier: MPL-2.0
 *
 * bluejay is free software.
 * For more information on the license, see LICENSE.
 * For more information on free software, see <https://www.gnu.org/philosophy/free-sw.en.html>.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at <https://mozilla.org/MPL/2.0/>.
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.statefulapp as StatefulApp

import io.github.ebonjaeger.bluejay

StatefulApp.StatefulWindow {
    id: root

    property int minWideScreenWidth: 525
    property bool wideScreen: width >= minWideScreenWidth

    width: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 50
    height: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 28

    minimumWidth: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 16

    onWideScreenChanged: Kirigami.Settings.isMobile ? drawer.close() : (!wideScreen ? drawer.close() : drawer.open())

    application: App
    windowName: "main"

    function onCloseClicked() {
        pageStack.pop();
    }

    function onBackRequested(event): void {
        NavigationController.deviceAddress = "";
    }

    function onAboutBackRequested(event): void {
        NavigationController.aboutOpen = false;

        var device = BluezQt.Manager.deviceForAddress(NavigationController.deviceAddress);

        if (device === null) {
            NavigationController.deviceAddress = "";
        }
    }

    Connections {
        target: Bluetooth

        function onBlockedChanged(): void {
            if (!Bluetooth.blocked && !NavigationController.aboutOpen) {
                // Go back to the welcome page if Bluetooth is blocked
                NavigationController.deviceAddress = "";
            }
        }

        function onEnabledChanged(): void {
            if (!Bluetooth.enabled && !NavigationController.aboutOpen) {
                // Go back to the welcome page if Bluetooth is disabled
                NavigationController.deviceAddress = "";
            }
        }

        function onErrorOccurred(errorText: string): void {
            showPassiveNotification(errorText);
        }

        function onDeviceRemoved(address: string): void {
            if (address === NavigationController.deviceAddress && !NavigationController.aboutOpen) {
                NavigationController.deviceAddress = "";
            }
        }
    }

    Connections {
        target: Bluetooth.agent()

        function onPinRequested(deviceName: string, pin: string): void {
            const component = Qt.createComponent("io.github.ebonjaeger.bluejay", "PasskeyDialog");
            const dialog = component.createObject(root, {
                deviceName: deviceName,
                passkey: pin
            });
            dialog.show();
        }

        function onConfirmationRequested(deviceName: string, passkey: string, request: VoidRequest): void {
            const component = Qt.createComponent("io.github.ebonjaeger.bluejay", "ConfirmationDialog");
            const dialog = component.createObject(root, {
                deviceName: deviceName,
                passkey: passkey,
                request: request
            });
            dialog.open();
        }
    }

    Connections {
        target: NavigationController

        function onDeviceAddressChanged() {
            var device = BluezQt.Manager.deviceForAddress(NavigationController.deviceAddress);

            // If no device, e.g. when the back button was clicked,
            // clear the stack and push the Welcome Page.
            if (device === null) {
                pageStack.clear();
                pageStack.push(Qt.createComponent("io.github.ebonjaeger.bluejay", "WelcomePage").createObject(pageStack));
                return;
            }

            const component = Qt.createComponent("io.github.ebonjaeger.bluejay", "DevicePage");

            if (component.status !== Component.Ready) {
                console.error(component.errorString());
                return;
            }

            const page = component.createObject(pageStack, {
                device: device
            });

            page.backRequested.connect(onBackRequested);

            // TODO: Evan: We can't check the NavigationController here, since the page is already
            // created by this point, and thus the deviceAddress property is already set.
            // Which means that the WelcomePage will always be removed when the page is pushed.
            if (pageStack.items.length === 2) {
                pageStack.pop();
            }

            pageStack.push(page);
        }
    }

    Component.onCompleted: {
        if (Kirigami.Settings.isMobile) {
            drawer.close();
        } else {
            drawer.open();
        }
    }

    pageStack {
        initialPage: WelcomePage {}
        columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn

        globalToolBar {
            style: Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.Auto
            showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton
        }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer
        modal: Kirigami.Settings.isMobile ? true : false
        width: 16 * Kirigami.Units.gridUnit
        leftPadding: 0
        topPadding: 0
        rightPadding: 0
        bottomPadding: 0

        Component.onCompleted: {
            if (Kirigami.Settings.isMobile) {
                drawer.close();
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration * 2
                easing.type: Easing.InOutQuart
            }
        }

        contentItem: ColumnLayout {
            spacing: 0

            Controls.ToolBar {
                Layout.fillWidth: true
                Layout.preferredHeight: root.pageStack.globalToolBar.preferredHeight
                leftPadding: 0
                rightPadding: 0

                contentItem: Item {
                    Controls.ToolButton {
                        id: menuButton
                        icon.name: "application-menu"
                        onClicked: menu.popup()
                        x: Kirigami.Units.smallSpacing

                        Behavior on x {
                            NumberAnimation {
                                duration: Kirigami.Units.shortDuration * 2
                                easing.type: Easing.InOutQuart
                            }
                        }

                        Controls.Menu {
                            id: menu

                            Kirigami.Action {
                                id: toggleBluetoothAction
                                text: i18n("Toggle Bluetooth")
                                tooltip: i18n("Turn Bluetooth on or off")
                                icon.name: "network-bluetooth-symbolic"
                                onTriggered: Bluetooth.toggle()
                            }

                            Kirigami.Action {
                                id: toggleDiscoveryAction
                                text: i18n("Toggle discovery")
                                tooltip: i18n("Turn device discovery on or off")
                                icon.name: "system-search-symbolic"
                                enabled: Bluetooth.enabled
                                onTriggered: Bluetooth.setDiscovering(!Bluetooth.discovering)
                            }

                            Controls.MenuSeparator {}

                            Kirigami.Action {
                                text: i18n("About")
                                tooltip: i18n("Show application information")
                                icon.name: "help-about-symbolic"

                                onTriggered: {
                                    const component = Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutPage");
                                    const page = component.createObject(root.pageStack);

                                    page.backRequested.connect(onAboutBackRequested);
                                    root.pageStack.push(page);

                                    NavigationController.aboutOpen = true;
                                }
                            }
                        }
                    }

                    Kirigami.Heading {
                        text: i18n("Devices")
                        horizontalAlignment: Qt.AlignHCenter
                        width: parent.width
                        x: 0
                        y: Kirigami.Units.smallSpacing
                    }

                    Controls.BusyIndicator {
                        visible: Bluetooth.discovering
                        hoverEnabled: true
                        Controls.ToolTip.text: i18nc("Tooltip shown when hovering over a spinner", "Discovering devices...")
                        Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
                        Controls.ToolTip.visible: hovered
                        x: parent.width - width - Kirigami.Units.smallSpacing
                    }
                }
            }

            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: deviceList

                    clip: true

                    Layout.fillWidth: true

                    DevicesProxyModel {
                        id: devicesModel
                        sourceModel: BluezQt.DevicesModel {}
                    }

                    Kirigami.PlaceholderMessage {
                        visible: Bluetooth.enabled && !Bluetooth.blocked && deviceList.count === 0
                        icon.name: "network-bluetooth-activated-symbolic"
                        text: i18n("No paired devices")
                        implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
                        anchors.centerIn: parent
                    }

                    model: BluezQt.Manager.bluetoothOperational ? devicesModel : null

                    section.property: "Section"
                    section.delegate: Kirigami.ListSectionHeader {
                        required property string section

                        Layout.fillWidth: true
                        text: switch (section) {
                            case "Connected":
                                return i18n("Connected");
                            case "Paired":
                                return i18n("Paired");
                            default:
                                return i18n("Available");
                        }
                    }

                    delegate: DeviceDelegate {
                        address: model.Address
                        name: model.Name
                        iconName: model.Icon
                        device: model.Device
                    }
                }
            }
        }
    }
}
