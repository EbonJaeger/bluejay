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

    property bool busy: false

    function makeCall(call: BluezQt.PendingCall): void {
        page.busy = true;
        call.finished.connect(call => {
            page.busy = false;
            if (call.error) {
                var message = Bluejay.Bluetooth.errorText(call.error);
                root.showPassiveNotification(message);
            } else {
                root.showPassiveNotification(i18n("Connected to device '%1'", page.device.name));
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

    Kirigami.OverlaySheet {
        visible: page.busy
        showCloseButton: false
        header: null
        footer: null
        implicitWidth: 96 + Kirigami.Units.largeSpacing
        implicitHeight: 96 + Kirigami.Units.largeSpacing

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Controls.BusyIndicator {
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: 96
                implicitHeight: 96
            }
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
        title: i18n("Device Settings")
    }

    FormCard.FormCard {
        enabled: !page.busy

        FormButton {
            text: i18n("Pair")
            description: i18n("Pair with this device")
            visible: !page.device.paired
            onClicked: page.makeCall(page.device.pair())
        }

        FormButton {
            text: if (page.device.connected) {
                return i18n("Disconnect");
            } else {
                return i18n("Connect");
            }
            description: if (page.device.connected) {
                return i18n("Disconnect from this device");
            } else {
                return i18n("Connect to this device");
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

        FormCard.FormDelegateSeparator {}

        FormCard.FormButtonDelegate {
            text: i18n("Manage")
            description: i18n("Additional settings for this device")
            onClicked: {
                trusted.visible = !trusted.visible;
                blocked.visible = !blocked.visible;
            }
        }

        FormCard.FormSwitchDelegate {
            id: trusted
            visible: false
            enabled: page.device.paired
            checked: page.device.trusted
            text: i18n("Trusted")
            description: i18n("Allow incoming connections from this device without confirmation")
            onToggled: Bluejay.Bluetooth.setDeviceTrusted(page.device.address, checked)
        }

        FormCard.FormSwitchDelegate {
            id: blocked
            visible: false
            checked: page.device.blocked
            text: i18n("Blocked")
            description: i18n("Reject incoming connections from this device")
            onToggled: Bluejay.Bluetooth.setDeviceBlocked(page.device.address, checked)
        }
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
}
