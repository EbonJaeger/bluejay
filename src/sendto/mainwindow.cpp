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

#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "devicerow.h"

MainWindow::MainWindow(QWidget * parent)
    : QMainWindow(parent)
    , manager(new BluezQt::Manager)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    auto initJob = manager->init();
    connect(initJob, &BluezQt::InitManagerJob::result,
                     this, &MainWindow::initialized);
    initJob->start();
}

MainWindow::~MainWindow() noexcept
{
    delete manager;
    delete ui;
}

void MainWindow::initialized(BluezQt::InitManagerJob * job)
{
    if (!manager->isInitialized())
    {
        qWarning() << "Could not initialize Bluez manager";
        return;
    }

    // Get the current list of devices
    auto devices = manager->devices();
    for (const auto & device : manager->devices())
    {
        deviceAdded(device);
    }

    // Connect the Bluez manager signals
    connect(manager, &BluezQt::Manager::deviceAdded,
                     this, &MainWindow::deviceAdded);

    connect(manager, &BluezQt::Manager::deviceRemoved,
                     this, &MainWindow::deviceRemoved);
}

void MainWindow::deviceAdded(BluezQt::DevicePtr device)
{
    qDebug() << "Device added:" << device->name();

    auto deviceRow = new DeviceRow(device);
    ui->devicesBox->addWidget(deviceRow);
}

void MainWindow::deviceRemoved(BluezQt::DevicePtr device)
{
    qDebug() << "Device removed:" << device->name();

    auto rows = ui->devicesBox->findChildren<DeviceRow *>(Qt::FindDirectChildrenOnly);
    for (const auto row : rows)
    {
        if (row->address() == device->address())
        {
            delete row;
        }
    }
}
