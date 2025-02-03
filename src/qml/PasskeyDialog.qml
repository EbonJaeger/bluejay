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
 *
 * SPDX-FileCopyrightText: Evan Maddock <maddock.evan@vivaldi.net>
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.PromptDialog {
    id: root

    property string deviceName
    property string passkey

    title: i18nc("@title:window", "Pairing Requested")
    subtitle: i18n("Pair request from <b>%1</b>.", root.deviceName)
    dialogType: Kirigami.PromptDialog.Information
    standardButtons: Kirigami.Dialog.Close

    ColumnLayout {
        Text {
            text: root.passkey
            font.pointSize: 24
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
