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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

import com.github.ebonjaeger.bluejay as Bluejay

Kirigami.Page {
    id: mainView

    readonly property BluezQt.Manager manager: BluezQt.Manager

    padding: 0

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

    actions: [
        Kirigami.Action {
            id: toggleBluetoothAction
            text: i18n("Toggle Bluetooth")
            icon.name: "network-bluetooth-symbolic"
            onTriggered: Bluejay.Bluetooth.toggle();
        },
        Kirigami.Action {
            id: toggleDiscoveryAction
            text: i18n("Toggle discovery")
            icon.name: "system-search-symbolic"
            onTriggered: Bluejay.Bluetooth.setDiscovering(!Bluejay.Bluetooth.discovering);
        },
        Kirigami.Action {
            text: i18n("About")
            icon.name: "help-about-symbolic"

            onTriggered: pageStack.pushDialogLayer(Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutPage"));
        }
    ]

    Connections {
        function onBluetoothBlockedChanged(blocked: bool) {
            toggleDiscoveryAction.enabled = !blocked;
        }

        target: manager
    }

    Connections {
        function onStateChanged(state: BluezQt.State) {
            var available = state !== BluezQt.Rfkill.Unknown;

            toggleBluetoothAction.enabled = available;
            toggleDiscoveryAction.enabled = available;
        }

        target: manager.rfkill
    }

    Connections {
        function onDeviceClicked(device: BluezQt.Device) {
            var devicePage = Qt.createComponent("DevicePage.qml");

            detailsPane.replace(null, devicePage, { "device": device });
        }

        target: scanner
    }

    Connections {
        function onDiscoveringChanged(): void {
            // headerBar.setDiscovering(Bluejay.Bluetooth.discovering);
        }

        function onErrorOccurred(errorText: string): void {
            errorMessage.text = errorText;
            errorMessage.visible = true;
        }

        target: Bluejay.Bluetooth
    }

    Component.onCompleted: {
        var available = manager.rfkill.state !== BluezQt.Rfkill.Unknown;
        var blocked = manager.bluetoothBlocked;

        toggleBluetoothAction.enabled = available;
        toggleDiscoveryAction.enabled = available;
    }

    ColumnLayout {
       anchors.fill: parent
       spacing: 0

       Kirigami.InlineMessage {
            id: errorMessage
            type: Kirigami.MessageType.Error
            showCloseButton: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.margins: 0
            implicitWidth: parent.width * 0.85
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            DeviceScanner {
                id: scanner
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.horizontalStretchFactor: 2
            }

            StackView {
                id: detailsPane

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.horizontalStretchFactor: 1
            }
        }
    }
}
