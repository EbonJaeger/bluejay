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
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigami.delegates as KD

import org.kde.bluezqt 1.0 as BluezQt

import com.github.ebonjaeger.bluejay

import "script.js" as Script

Item {
    id: root

    implicitHeight: Kirigami.Units.gridUnit * 28
    implicitWidth: Kirigami.Units.gridUnit * 28

    function setBluetoothEnabled(enabled) {
        BluezQt.Manager.bluetoothBlocked = !enabled;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enabled;
        }
    }

    function makeCall(call) {
        busyIndicator.running = true;

        call.finished.connect(call => {
            busyIndicator.running = false;

            if (call.error) {
                errorMessage.text = call.errorText;
                errorMessage.visible = true;
            }
        })
    }

    function infoText(type, battery, uuids): string {
        const labels = [];

        labels.push(Script.deviceTypeToString(type));

        if (battery) {
            labels.push(i18n("%1% Battery", battery.percentage));
        }

        return labels.join(" · ");
    }

    Kirigami.InlineMessage {
        id: errorMessage
        type: Kirigami.MessageType.Error
        showCloseButton: true
    }

    Kirigami.InlineMessage {
        id: testMessage
        type: Kirigami.MessageType.Information
        visible: BluezQt.Manager.operational
        text: "BluezQt Manager operational"
    }

    ListView {
        id: deviceList
        clip: true

        Kirigami.PlaceholderMessage {
            id: noBluetoothMessage
            visible: BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown
            icon.name: "edit-none-symbolic"
            text: i18n("No Bluetooth adapters found")
            explanation: i18n("Please connect a Bluetooth adapter")
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
        }

        Kirigami.PlaceholderMessage {
            id: bluetoothDisabledMessage
            visible: BluezQt.Manager.operational && !BluezQt.Manager.bluetoothOperational && !noBluetoothMessage.visible
            icon.name: "network-bluetooth-inactive-symbolic"
            text: i18n("Bluetooth is disabled")
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent

            helpfulAction: Kirigami.Action {
                icon.name: "network-bluetooth-symbolic"
                text: i18n("Enable")
                onTriggered: {
                    setBluetoothEnabled(true)
                }
            }
        }

        Kirigami.PlaceholderMessage {
            visible: !noBluetoothMessage.visible && !bluetoothDisabledMessage.visible && deviceList.count === 0
            icon.name: "network-bluetooth-activated-symbolic"
            text: i18n("No paired devices")
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
        }

        Controls.BusyIndicator {
            id: busyIndicator
            running: false
            anchors.centerIn: parent
        }

        DevicesProxyModel {
            id: devicesModel
            sourceModel: BluezQt.DevicesModel { }
        }

        model: BluezQt.Manager.bluetoothOperational ? devicesModel : null

        section.property: "Connected"
        section.delegate: Kirigami.ListSectionHeader {
            width: ListView.view.width
            text: section === "true" ? i18n("Connected") : i18n("Available")
        }

        delegate: Controls.ItemDelegate {
            width: ListView.view.width

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                KD.IconTitleSubtitle {
                    title: model.Name
                    subtitle: infoText(model.Device.type, model.Device.battery, model.Device.uuids)
                    icon.name: model.Icon
                    icon.width: Kirigami.Units.iconSizes.medium
                    Layout.fillWidth: true
                }
            }
        }
    }
}
