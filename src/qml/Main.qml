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

import com.github.ebonjaeger.bluejay as Bluejay

Kirigami.ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    title: i18nc("Bluejay is the name of the application", "Bluejay")

    function onCloseClicked() {
        pageStack.pop();
    }

    Connections {
        function onErrorOccurred(errorText: string): void {
            showPassiveNotification(errorText);
        }

        target: Bluejay.Bluetooth
    }

    Connections {
        function onDeviceClicked(device: BluezQt.Device) {
            var component = Qt.createComponent("DevicePage.qml");
            var page = component.createObject(pageStack, { "device": device });

            if (page == null) {
                console.error("Unable to create DevicePage");
                return;
            }

            page.closeClicked.connect(onCloseClicked);
            pageStack.push(page);
        }

        target: mainView
    }

    pageStack {
        initialPage: MainPage {
            id: mainView
        }
    }
}
