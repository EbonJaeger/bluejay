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

Kirigami.ScrollablePage {
    id: mainView

    readonly property BluezQt.Manager manager: BluezQt.Manager

    signal deviceClicked(device: BluezQt.Device)

    padding: 0
    title: i18n("Devices")

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

    actions: [
        Kirigami.Action {
            id: toggleBluetoothAction
            text: i18n("Toggle Bluetooth")
            tooltip: i18n("Turn Bluetooth on or off")
            icon.name: "network-bluetooth-symbolic"
            onTriggered: Bluejay.Bluetooth.toggle();
        },
        Kirigami.Action {
            id: toggleDiscoveryAction
            text: i18n("Toggle discovery")
            tooltip: i18n("Turn device discovery on or off")
            icon.name: "system-search-symbolic"
            onTriggered: Bluejay.Bluetooth.setDiscovering(!Bluejay.Bluetooth.discovering);
        },
        Kirigami.Action {
            text: i18n("About")
            tooltip: i18n("Show application information")
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
            deviceClicked(device);
        }

        target: scanner
    }

    Component.onCompleted: {
        var available = manager.rfkill.state !== BluezQt.Rfkill.Unknown;
        var blocked = manager.bluetoothBlocked;

        toggleBluetoothAction.enabled = available;
        toggleDiscoveryAction.enabled = available;
    }

    DeviceScanner {
        id: scanner
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
