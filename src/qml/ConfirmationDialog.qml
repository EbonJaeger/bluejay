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
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import com.github.ebonjaeger.bluejay as Bluejay

Kirigami.PromptDialog {
    id: root

    property string deviceName
    property string passkey
    property Bluejay.VoidRequest request

    title: i18nc("@title:window", "Pairing Requested")
    subtitle: i18n("Pair request from <b>%1</b>. Do you want to pair?", root.deviceName)
    dialogType: Kirigami.PromptDialog.Information
    standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.Cancel

    onAccepted: {
        console.debug("Pairing accepted");
        root.request.accept();
    }

    onRejected: {
        console.debug("Pairing cancelled");
        root.request.cancel();
    }

    ColumnLayout {
        Text {
            text: root.passkey
            font.pointSize: 24
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
