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

import org.kde.kirigami as Kirigami
import org.kde.kirigami.delegates as KD

import org.kde.bluezqt as BluezQt

import com.github.ebonjaeger.bluejay

import "script.js" as Script

Item {
    id: scanner
    width: root.width

    function toggleBluetooth(): void {
        var oldState = BluezQt.Manager.bluetoothBlocked;

        BluezQt.Manager.bluetoothBlocked = !oldState;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = oldState;
        }
    }

    function makeCall(call: BluezQt.PendingCall): void {
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

    ColumnLayout {
        width: root.width

        RowLayout {
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            Controls.Switch {
                text: i18n("Bluetooth enabled")
                enabled: BluezQt.Manager.rfkill.state !== BluezQt.Rfkill.Unknown
                checked: !BluezQt.Manager.bluetoothBlocked
                onToggled: toggleBluetooth()
            }

            Controls.BusyIndicator {
                id: busyIndicator
                running: false
            }
        }

        Kirigami.InlineMessage {
            id: errorMessage
            type: Kirigami.MessageType.Error
            showCloseButton: true
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: parent.width * 0.85
        }

        Kirigami.ScrollablePage {
            Layout.fillWidth: true
            implicitHeight: root.height

            ListView {
                id: deviceList

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
                        onTriggered: toggleBluetooth()
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

                model: BluezQt.Manager.bluetoothOperational ? devicesModel : null

                section.property: "Connected"
                section.delegate: Kirigami.ListSectionHeader {
                    Layout.fillWidth: true
                    text: section === "true" ? i18n("Connected") : i18n("Available")
                }

                delegate: Controls.ItemDelegate {
                    id: delegate

                    required property var model

                    implicitWidth: parent.width

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        KD.IconTitleSubtitle {
                            title: model.Name
                            subtitle: infoText(model.Device.type, model.Device.battery, model.Device.uuids)
                            icon.name: model.Icon
                            icon.width: Kirigami.Units.iconSizes.medium
                        }

                        Controls.ToolButton {
                            text: delegate.model.Connected ? i18n("Disconnect") : i18n("Connect")
                            icon.name: delegate.model.Connected ? "network-disconnect-symbolic" : "network-connect-symbolic"
                            display: Controls.AbstractButton.IconOnly

                            Controls.ToolTip.text: text
                            Controls.ToolTip.visible: hovered

                            onClicked: {
                                if (delegate.model.Connected) {
                                    makeCall(delegate.model.Device.disconnectFromDevice())
                                } else {
                                    makeCall(delegate.model.Device.connectToDevice())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
