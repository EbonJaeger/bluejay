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

#include "devicerow.h"
#include "ui_devicerow.h"

DeviceRow::DeviceRow(BluezQt::DevicePtr device, QWidget * parent)
    : QWidget(parent)
    , device(device)
    , ui(new Ui::DeviceRow)
{
    ui->setupUi(this);

    auto icon = QIcon::fromTheme(device->icon());
    auto pixmap = icon.pixmap(QSize(32, 32));

    QString tooltipText;
    tooltipText = tooltipText.arg("%s\n%s", device->name(), device->address());

    ui->image->setPixmap(pixmap);
    ui->name->setText(device->name());
    ui->name->setToolTip(tooltipText);
    ui->type->setText(getNameFromType(device->type()));
}

DeviceRow::~DeviceRow() noexcept
{
    delete ui;
}

QString DeviceRow::address()
{
    return device->address();
}

QString DeviceRow::getNameFromType(BluezQt::Device::Type type)
{
    switch (type) {
        case BluezQt::Device::Type::Phone:
            return QString("Phone");
        case BluezQt::Device::Type::Modem:
            return QString("Modem");
        case BluezQt::Device::Type::Computer:
            return QString("Computer");
        case BluezQt::Device::Type::Network:
            return QString("Network");
        case BluezQt::Device::Type::Headset:
            return QString("Headset");
        case BluezQt::Device::Type::Headphones:
            return QString("Headphones");
        case BluezQt::Device::Type::AudioVideo:
            return QString("Speakers");
        case BluezQt::Device::Type::Keyboard:
            return QString("Keyboard");
        case BluezQt::Device::Type::Mouse:
            return QString("Mouse");
        case BluezQt::Device::Type::Joypad:
            return QString("Controller");
        case BluezQt::Device::Type::Tablet:
            return QString("Tablet");
        case BluezQt::Device::Type::Peripheral:
            return QString("Input Device");
        case BluezQt::Device::Type::Camera:
            return QString("Camera");
        case BluezQt::Device::Type::Printer:
            return QString("Printer");
        case BluezQt::Device::Type::Imaging:
            return QString("Imaging Device");
        case BluezQt::Device::Type::Wearable:
            return QString("Smartwatch");
        case BluezQt::Device::Type::Toy:
            return QString("Toy");
        case BluezQt::Device::Type::Health:
            return QString("Health Device");
        case BluezQt::Device::Type::Uncategorized:
        default:
            return device->address();
    }
}
