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

#ifndef DEVICEROW_H
#define DEVICEROW_H

#include <BluezQt/Device>
#include <QWidget>

QT_BEGIN_NAMESPACE
namespace Ui {
    class DeviceRow;
}
QT_END_NAMESPACE

class DeviceRow : public QWidget
{
    Q_OBJECT

public:
    explicit DeviceRow(BluezQt::DevicePtr device, QWidget * parent = nullptr);
    ~DeviceRow() noexcept;

    QString address();

private:
    BluezQt::DevicePtr device;
    Ui::DeviceRow * ui;

    QString getNameFromType(BluezQt::Device::Type type);
};

#endif
