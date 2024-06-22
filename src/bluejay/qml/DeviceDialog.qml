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

import org.kde.kirigami as Kirigami

import org.kde.bluezqt as BluezQt

import "script.js" as Script

Window {
    id: deviceDialog

    required property BluezQt.Device device

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

    title: device.name
    width: 360
    height: 400

    MessageDialog {
        id: forgetDialog
        text: i18n("Are you sure you want to forget this device?")
        informativeText: i18n("If you want to connect to this device after forgetting, you will have to pair it again.")
        buttons: MessageDialog.Yes | MessageDialog.Cancel
        onAccepted: {
            var adapter = device.adapter;
            makeCall(adapter.removeDevice(device));
        }
    }

    Controls.Page {
        width: deviceDialog.width

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
                text: device.name
                Kirigami.FormData.label: i18n("Name:")
            }

            Controls.Label {
                text: device.address
                Kirigami.FormData.label: i18n("Address:")
            }

            Controls.Label {
                text: Script.deviceTypeToString(device.type)
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
                text: i18n("%1%", device.battery !== null ? device.battery.percentage : "Unknown")
                Kirigami.FormData.label: i18n("Battery:")
            }
        }

        footer: Controls.ToolBar {
            RowLayout {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                layoutDirection: Qt.RightToLeft

                Controls.ToolButton {
                    text: i18n("Forget")
                    visible: device.paired
                    enabled: !busyIndicator.running
                    onClicked: forgetDialog.open()
                }

                Controls.ToolButton {
                    text: i18n("Pair")
                    visible: !device.paired
                    enabled: !busyIndicator.running
                }

                Controls.ToolButton {
                    id: connectionButton
                    text: device.connected ? i18n("Disconnect") : i18n("Connect")
                    enabled: !busyIndicator.running
                    onClicked: {
                        if (delegate.model.Connected) {
                            makeCall(device.disconnectFromDevice());
                        } else {
                            makeCall(device.connectToDevice());
                        }
                    }
                }

                Controls.BusyIndicator {
                    id: busyIndicator
                    running: false
                }
            }
        }
    }
}
