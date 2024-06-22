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

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami

Controls.Page {
    id: mainView

    function toggleBluetooth(): void {
        var oldState = BluezQt.Manager.bluetoothBlocked;

        BluezQt.Manager.bluetoothBlocked = !oldState;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = oldState;
        }
    }

    header: Controls.ToolBar {
        id: headerBar

        ColumnLayout {
            width: headerBar.width

            RowLayout {
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
        }
    }

    RowLayout {
        height: mainView.height

        DeviceScanner {
            width: mainView.width * 0.66
            height: mainView.height
        }
    }
}
