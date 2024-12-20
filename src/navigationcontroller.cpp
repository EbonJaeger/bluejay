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

#include "navigationcontroller.h"

NavigationController::NavigationController(QObject *parent)
    : QObject(parent)
{
}

QString NavigationController::deviceAddress() const
{
    return m_deviceAddress;
}

void NavigationController::setDeviceAddress(const QString &address)
{
    if (address == m_deviceAddress) {
        return;
    }

    m_deviceAddress = address;

    Q_EMIT deviceAddressChanged();
}

#include "moc_navigationcontroller.cpp"
