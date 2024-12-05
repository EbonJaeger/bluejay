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
import QtQuick.Dialogs
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import com.github.ebonjaeger.bluejay as Bluejay

FormCard.FormCardPage {
    id: page

    required property BluezQt.Device device

    function makeCall(call: BluezQt.PendingCall): void {
        busyIndicator.running = true;
        call.finished.connect(call => {
            busyIndicator.running = false;
            if (call.error) {
                var message = Bluejay.Bluetooth.errorText(call.error);
                root.showPassiveNotification(message);
            }
        });
    }

    MessageDialog {
        id: forgetDialog
        text: i18n("Are you sure you want to forget this device?")
        informativeText: i18n("If you want to connect to this device after forgetting, you will have to pair it again.")
        buttons: MessageDialog.Yes | MessageDialog.Cancel
        onAccepted: {
            const {
                adapter
            } = page.device;
            page.makeCall(adapter.removeDevice(device));
        }
    }

    titleDelegate: RowLayout {
        Layout.fillWidth: true

        Kirigami.Heading {
            id: heading
            text: page.device.name
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            horizontalAlignment: Text.AlignHCenter
            elide: Qt.ElideRight
        }
    }

    Kirigami.Icon {
        Layout.fillWidth: true
        source: page.device.icon
        implicitWidth: 96
        implicitHeight: 96
    }

    FormCard.FormHeader {
        title: i18n("Status")
    }

    FormCard.FormCard {
        FormCard.FormTextDelegate {
            text: i18n("Address")
            description: page.device.address
        }

        FormCard.FormTextDelegate {
            text: i18n("Type")
            description: Bluejay.Bluetooth.deviceTypeToString(device.type, device.uuids)
        }

        FormCard.FormTextDelegate {
            text: i18n("Paired")
            description: page.device.paired ? i18n("Yes") : i18n("No")
        }

        FormCard.FormTextDelegate {
            text: i18n("Connected")
            description: page.device.connected ? i18n("Yes") : i18n("No")
        }

        FormCard.FormTextDelegate {
            visible: page.device.battery !== null
            text: i18n("Battery")
            description: i18n("%1%", page.device.battery !== null ? page.device.battery.percentage : i18nc("Shown when there is no battery information for a device", "Unknown"))
        }
    }

    FormCard.FormHeader {
        title: i18n("Device Settings")
    }

    FormCard.FormCard {
        FormCard.FormSectionText {
            text: i18nc("Section header for access settings on a Bluetooth device", "Access")
        }

        FormCard.FormSwitchDelegate {
            id: trusted
            enabled: !busyIndicator.running && page.device.paired
            checked: page.device.trusted
            text: i18n("Trusted")
            description: i18n("Allow incoming connections from this device without confirmation")
            onToggled: Bluejay.Bluetooth.setDeviceTrusted(page.device.address, checked)
        }

        FormCard.FormSwitchDelegate {
            id: blocked
            enabled: !busyIndicator.running
            checked: page.device.blocked
            text: i18n("Blocked")
            description: i18n("Reject incoming connections from this device")
            onToggled: Bluejay.Bluetooth.setDeviceBlocked(page.device.address, checked)
        }

        Kirigami.Separator {
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
        }

        FormCard.FormSectionText {
            text: i18nc("Section header for device management", "Manage")
        }

        FormButton {
            text: i18n("Pair")
            description: i18n("Pair with this device")
            visible: !page.device.paired
            onClicked: page.makeCall(page.device.pair())
        }

        FormButton {
            text: if (page.device.connected) {
                return i18n("Disconnect")
            } else {
                return i18n("Connect")
            }
            description: if (page.device.connected) {
                return i18n("Disconnect from this device")
            } else {
                return i18n("Connect to this device")
            }
            onClicked: {
                if (page.device.connected) {
                    page.makeCall(page.device.disconnectFromDevice());
                } else {
                    page.makeCall(page.device.connectToDevice());
                }
            }
        }

        FormButton {
            text: i18n("Forget")
            description: i18n("Forget this device")
            visible: page.device.paired
            onClicked: forgetDialog.open()
        }
    }

    footer: Kirigami.ActionToolBar {
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
