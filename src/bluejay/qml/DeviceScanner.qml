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
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.2

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

import com.github.ebonjaeger.bluejay

ColumnLayout {
    readonly property BluezQt.Manager manager: BluezQt.Manager

    signal deviceClicked(device: BluezQt.Device)

    Kirigami.ScrollablePage {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: deviceList

            Kirigami.PlaceholderMessage {
                id: noBluetoothMessage
                visible: manager.rfkill.state === BluezQt.Rfkill.Unknown
                icon.name: "edit-none-symbolic"
                text: i18n("No Bluetooth adapters found")
                explanation: i18n("Please connect a Bluetooth adapter")
                implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
                anchors.centerIn: parent
            }

            Kirigami.PlaceholderMessage {
                id: bluetoothDisabledMessage
                visible: manager.operational && !manager.bluetoothOperational && !noBluetoothMessage.visible
                icon.name: "network-bluetooth-inactive-symbolic"
                text: i18n("Bluetooth is disabled")
                implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
                anchors.centerIn: parent

                helpfulAction: Kirigami.Action {
                    icon.name: "network-bluetooth-symbolic"
                    text: i18n("Enable")
                    onTriggered: mainView.toggleBluetooth()
                }
            }

            Kirigami.PlaceholderMessage {
                visible: !noBluetoothMessage.visible && !bluetoothDisabledMessage.visible && deviceList.count === 0
                icon.name: "network-bluetooth-activated-symbolic"
                text: i18n("No paired devices")
                implicitWidth: parent.width - (Kirigami.Units.largeSpacing * 4)
                anchors.centerIn: parent
            }

            DevicesProxyModel {
                id: devicesModel
                sourceModel: BluezQt.DevicesModel { }
            }

            model: manager.bluetoothOperational ? devicesModel : null

            section.property: "Connected"
            section.delegate: Kirigami.ListSectionHeader {
                Layout.fillWidth: true
                text: section === "true" ? i18n("Connected") : i18n("Available")
            }

            delegate: Device {
                onClicked: deviceClicked(model.Device)
            }
        }
    }
}
