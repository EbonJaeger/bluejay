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

import "./delegates"

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

import com.github.ebonjaeger.bluejay as Bluejay

Page {
    id: mainView

    readonly property BluezQt.Manager manager: BluezQt.Manager

    function checkDiscovering(): bool {
        for (var i = 0; i < manager.adapters.length; ++i) {
            var adapter = manager.adapters[i];
            if (adapter.discovering) {
                return true;
            }
        }

        return false;
    }

    function toggleBluetooth(): void {
        var oldState = manager.bluetoothBlocked;

        manager.bluetoothBlocked = !oldState;

        for (var i = 0; i < manager.adapters.length; ++i) {
            var adapter = manager.adapters[i];
            adapter.powered = oldState;
        }
    }

    function toggleDiscovering(): void {
        var discovering = checkDiscovering();

        // Set the new state to all adapters
        for (var i = 0; i < manager.adapters.length; ++i) {
            var adapter = manager.adapters[i];
            var call = discovering ? adapter.stopDiscovery() : adapter.startDiscovery();

            call.finished.connect(call => {
                if (call.error) {
                    errorMessage.text = call.errorText;
                    errorMessage.visible = true;
                }
            });
        }
    }

    header: HeaderBar {
        id: headerBar
    }

    Connections {
        function onBluetoothToggled() {
            toggleBluetooth();
        }

        function onDiscoveringToggled() {
            toggleDiscovering();
        }

        target: headerBar
    }

    Connections {
        function onBluetoothBlockedChanged(blocked: bool) {
            headerBar.setBluetoothBlocked(blocked);
        }

        function onAdapterAdded(adapter: BluezQt.Adapter) {
            adapter.discoveringChanged.connect(discovering => {
                headerBar.setDiscovering(discovering);
            });
        }

        target: manager
    }

    Connections {
        function onStateChanged(state: BluezQt.State) {
            var available = state !== BluezQt.Rfkill.Unknown;

            headerBar.setBluetoothAvailable(available);
        }

        target: manager.rfkill
    }

    Connections {
        function onDeviceClicked(device: BluezQt.Device) {
            // TODO: Is there a better way than this, or is this correct?
            var devicePage = Qt.createComponent("qrc:/qt/qml/com/github/ebonjaeger/bluejay/qml/DevicePage.qml");

            detailsPane.replace(null, devicePage, { "device": device });
        }

        target: scanner
    }

    Connections {
        function onErrorOccurred(errorText: str): void {
            errorMessage.text = errorText;
            errorMessage.visible = true;
        }

        target: Bluejay.Bluetooth
    }

    Component.onCompleted: {
        var available = manager.rfkill.state !== BluezQt.Rfkill.Unknown;
        var blocked = manager.bluetoothBlocked;
        var discovering = false;

        for (var i = 0; i < manager.adapters.length; ++i) {
            var adapter = manager.adapters[i];

            if (adapter.discovering) {
                discovering = true;
            }

            adapter.discoveringChanged.connect(dis => {
                headerBar.setDiscovering(dis);
            });
        }

        headerBar.setBluetoothAvailable(available);
        headerBar.setBluetoothBlocked(blocked);
        headerBar.setDiscovering(discovering);
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
