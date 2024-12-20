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
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigami.delegates as Delegates
import org.kde.kirigamiaddons.delegates

import org.kde.bluezqt as BluezQt

import com.github.ebonjaeger.bluejay

RoundedItemDelegate {
    id: root

    required property string address
    required property string name
    required property string iconName
    required property BluezQt.Device device
    required property var model

    highlighted: NavigationController.deviceAddress === address
    activeFocusOnTab: true

    function infoText(device: BluezQt.Device): string {
        const {
            battery,
            type,
            uuids
        } = device;
        const labels = [];
        labels.push(Bluetooth.deviceTypeToString(type, uuids));
        if (battery) {
            labels.push(i18n("%1% Battery", battery.percentage));
        }
        return labels.join(" · ");
    }

    implicitWidth: parent.width

    contentItem: Delegates.IconTitleSubtitle {
        title: root.name
        subtitle: infoText(root.device)
        icon.name: root.iconName
    }

    TapHandler {
        onTapped: NavigationController.deviceAddress = root.address
    }

    Controls.ToolTip.text: root.name
    Controls.ToolTip.visible: hovered
    Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
}
