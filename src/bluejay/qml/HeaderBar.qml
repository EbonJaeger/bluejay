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

ToolBar {
    signal bluetoothToggled()

    function setBluetoothAvailable(available: bool) {
        bluetoothSwitch.enabled = available;
    }

    function setBluetoothBlocked(blocked: bool) {
        bluetoothSwitch.checked = !blocked;
    }

    ColumnLayout {
        width: parent.width

        RowLayout {
            Switch {
                id: bluetoothSwitch
                text: i18n("Bluetooth enabled")
                onToggled: bluetoothToggled()
            }

            BusyIndicator {
                id: busyIndicator
                running: false
            }
        }

        // TODO: Message area
    }
}
