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
import QtQuick.Dialogs
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

import "script.js" as Script

Kirigami.Page {
    required property BluezQt.Device device

    signal closeClicked()

    title: device.name

    actions: [
        Kirigami.Action {
            tooltip: "Close device page"
            icon.name: "dialog-close-symbolic"
            onTriggered: closeClicked()
        }
    ]

    function makeCall(call: BluezQt.PendingCall): void {
        busyIndicator.running = true;

        call.finished.connect(call => {
            busyIndicator.running = false;

            if (call.error) {
                var message = Bluetooth.errorText(call.error);

                root.showPassiveNotification(message);
            }
        })
    }

    MessageDialog {
        id: forgetDialog
        text: i18n("Are you sure you want to forget this device?")
        informativeText: i18n("If you want to connect to this device after forgetting, you will have to pair it again.")
        buttons: MessageDialog.Yes | MessageDialog.Cancel
        onAccepted: {
            const { adapter } = device;
            makeCall(adapter.removeDevice(device));
        }
    }

    header: Controls.ToolBar {
        implicitWidth: 96
        implicitHeight: 96

        Kirigami.Icon {
            source: device.icon
            width: 96
            height: 96
            anchors.fill: parent
        }
    }

    contentItem: Kirigami.FormLayout {
        anchors.topMargin: 8
        anchors.bottomMargin: 8

        Controls.Label {
            text: device.address
            Kirigami.FormData.label: i18n("Address:")
        }

        Controls.Label {
            text: Script.deviceTypeToString(device)
            Kirigami.FormData.label: i18n("Type:")
        }

        Controls.Label {
            text: device.paired ? i18n("Yes") : i18n("No")
            Kirigami.FormData.label: i18n("Paired:")
        }

        Controls.Label {
            text: device.trusted ? i18n("Yes") : i18n("No")
            Kirigami.FormData.label: i18n("Trusted:")
        }

        Controls.Label {
            text: device.connected ? i18n("Yes") : i18n("No")
            Kirigami.FormData.label: i18n("Connected:")
        }

        Controls.Label {
            visible: device.battery !== null
            text: i18n("%1%", device.battery !== null ? device.battery.percentage : i18nc("Shown when there is no battery information for a device", "Unknown"))
            Kirigami.FormData.label: i18n("Battery:")
        }
    }

    footer: Kirigami.ActionToolBar {
        actions: [
            Kirigami.Action {
                text: i18n("Forget")
                tooltip: i18n("Forget this device")
                visible: device.paired
                enabled: !busyIndicator.running
                onTriggered: forgetDialog.open()
            },

            Kirigami.Action {
                text: i18n("Pair")
                tooltip: i18n("Start pairing process")
                visible: !device.paired
                enabled: !busyIndicator.running
            },

            Kirigami.Action {
                text: device.connected ? i18n("Disconnect") : i18n("Connect")
                tooltip: device.connected ? i18n("Disconnect from this device") : i18n("Connect to this device")
                enabled: !busyIndicator.running
                onTriggered: {
                    if (device.Connected) {
                        makeCall(device.disconnectFromDevice());
                    } else {
                        makeCall(device.connectToDevice());
                    }
                }
            }
        ]

        alignment: Qt.AlignRight

        anchors.left: parent.left
        anchors.right: parent.right

        position: Controls.ToolBar.Footer

        Controls.BusyIndicator {
            id: busyIndicator
            running: false
        }
    }
}
