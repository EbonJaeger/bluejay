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

#pragma once

#include <QObject>
#include <QQmlEngine>

class NavigationController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    /// This property holds the current device address.
    Q_PROPERTY(QString deviceAddress READ deviceAddress WRITE setDeviceAddress NOTIFY deviceAddressChanged)

    /// This property holds whether or not the About page is open.
    Q_PROPERTY(bool aboutOpen READ aboutOpen WRITE setAboutOpen NOTIFY aboutOpenChanged)

public:
    explicit NavigationController(QObject *parent = nullptr);
    ~NavigationController() override = default;

    QString deviceAddress() const;
    void setDeviceAddress(const QString &address);

    bool aboutOpen() const;
    void setAboutOpen(bool open);

Q_SIGNALS:
    void deviceAddressChanged();
    void aboutOpenChanged();

private:
    QString m_deviceAddress;
    bool m_aboutOpen;
};
