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

import org.kde.bluezqt as BluezQt

import "script.js" as Script

Controls.ItemDelegate {
    id: delegate

    required property var model

    function infoText(device: BluezQt.Device): string {
        const {
            battery
        } = device;
        const labels = [];
        labels.push(Script.deviceTypeToString(device));
        if (battery) {
            labels.push(i18n("%1% Battery", battery.percentage));
        }
        return labels.join(" · ");
    }

    implicitWidth: parent.width

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Delegates.IconTitleSubtitle {
            title: model.Name
            subtitle: infoText(model.Device)
            icon.name: model.Icon
            icon.width: Kirigami.Units.iconSizes.medium
        }
    }
}
