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

import "./components"

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

ToolBar {
    signal bluetoothToggled()
    signal discoveringToggled()

    function setBluetoothAvailable(available: bool): void {
        bluetoothButton.enabled = available;
        discoveringButton.enabled = available;
    }

    function setBluetoothBlocked(blocked: bool): void {
        bluetoothButton.text = blocked ? i18n("Enable Bluetooth") : i18n("Disable Bluetooth");
        bluetoothButton.icon.name = blocked ? "network-bluetooth-inactive-symbolic" : "network-bluetooth-symbolic";
    }

    function setDiscovering(discovering: bool): void {
        discoveringButton.text = discovering ? i18n("Stop discovering") : i18n("Start discovering");
    }

    RowLayout {
        anchors.fill: parent

        HeaderButton {
            id: bluetoothButton

            display: AbstractButton.TextBesideIcon

            text: i18n("Disable Bluetooth")
            icon.name: "network-bluetooth-symbolic"

            onClicked: bluetoothToggled()
        }

        HeaderButton {
            id: discoveringButton

            display: AbstractButton.TextBesideIcon

            text: i18n("Start discovery")
            icon.name: "system-search-symbolic"

            onClicked: discoveringToggled()
        }

        BusyIndicator {
            id: busyIndicator
            running: false
        }

        // Blank item to separate the left and right sides of the bar
        Item {
            Layout.fillWidth: true
        }

        HeaderButton {
            id: menuButton

            function openMenu() {
                if (!menu.visible) {
                    menu.open();
                } else {
                    menu.dismiss();
                }
            }

            text: i18n("Application Menu")
            icon.name: "open-menu-symbolic"

            onClicked: openMenu()

            menu: ApplicationMenu {
                y: menuButton.height
                modal: true
                dim: false
            }
        }
    }
}
