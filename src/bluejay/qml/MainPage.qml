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

Page {
    id: mainView

    readonly property BluezQt.Manager manager: BluezQt.Manager

    function toggleBluetooth(): void {
        var oldState = manager.bluetoothBlocked;

        manager.bluetoothBlocked = !oldState;

        for (var i = 0; i < manager.adapters.length; ++i) {
            var adapter = manager.adapters[i];
            adapter.powered = oldState;
        }
    }

    header: HeaderBar {
        id: headerBar
    }

    Connections {
        function onBluetoothToggled() {
            toggleBluetooth();
        }

        target: headerBar
    }

    Connections {
        function onBluetoothBlockedChanged(blocked: bool) {
            headerBar.setBluetoothBlocked(blocked);
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

    Component.onCompleted: {
        var available = manager.rfkill.state !== BluezQt.Rfkill.Unknown;
        var blocked = manager.bluetoothBlocked;

        headerBar.setBluetoothAvailable(available);
        headerBar.setBluetoothBlocked(blocked);
    }

    RowLayout {
        anchors.fill: parent

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
