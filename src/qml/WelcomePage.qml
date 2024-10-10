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

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

import com.github.ebonjaeger.bluejay as Bluejay

Kirigami.Page {
    id: root

    Kirigami.PlaceholderMessage {
        id: noBluetoothMessage
        visible: BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown
        icon.name: "edit-none-symbolic"
        text: i18n("No Bluetooth adapters found")
        explanation: i18n("Please connect a Bluetooth adapter")
        implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
        anchors.centerIn: parent
    }

    Kirigami.PlaceholderMessage {
        id: bluetoothDisabledMessage
        visible: BluezQt.Manager.operational && !BluezQt.Manager.bluetoothOperational && !noBluetoothMessage.visible
        icon.name: "network-bluetooth-inactive-symbolic"
        text: i18n("Bluetooth is disabled")
        implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
        anchors.centerIn: parent

        helpfulAction: Kirigami.Action {
            icon.name: "network-bluetooth-symbolic"
            text: i18n("Enable")
            onTriggered: Bluejay.Bluetooth.toggle()
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        visible: !noBluetoothMessage.visible && !bluetoothDisabledMessage.visible
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        icon.name: "network-bluetooth"
        text: i18n("No device selected. Click a device to get started.")
    }
}
