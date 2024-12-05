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
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

FormCard.AbstractFormDelegate {
    id: root

    property string description: ""

    property alias descriptionItem: internalDescriptionItem

    focusPolicy: Qt.StrongFocus

    contentItem: RowLayout {
        spacing: 0

        Kirigami.Icon {
            visible: root.icon.name !== ""
            source: root.icon.name
            color: root.icon.color
            Layout.rightMargin: (root.icon.name !== "") ? Kirigami.Units.largeSpacing : 0
            implicitWidth: (root.icon.name !== "") ? root.icon.width : 0
            implicitHeight: (root.icon.name !== "") ? root.icon.height : 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: root.text
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
                color: root.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                Accessible.ignored: true // base class sets this text on root already
            }

            Label {
                id: internalDescriptionItem
                Layout.fillWidth: true
                visible: root.description !== ""
                text: root.description
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                color: Kirigami.Theme.disabledTextColor
                Accessible.ignored: !visible
            }
        }
    }

    Accessible.onPressAction: action ? action.trigger() : root.clicked()
}
