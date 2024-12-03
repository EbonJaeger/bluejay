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

#pragma once

#include <BluezQt/Agent>
#include <BluezQt/Device>

#include "voidrequest.h"

namespace Bluejay
{
class BtAgent : public BluezQt::Agent
{
    Q_OBJECT

public:
    explicit BtAgent(QObject *parent = nullptr);

    QString pin() const;
    void setPin(const QString& pin);
    QString generatePin(const BluezQt::DevicePtr& device);

    QDBusObjectPath objectPath() const override;

    void requestPinCode(BluezQt::DevicePtr device, const BluezQt::Request<QString> &request) override;
    void displayPinCode(BluezQt::DevicePtr device, const QString &pinCode) override;
    void requestPasskey(BluezQt::DevicePtr device, const BluezQt::Request<quint32> &request) override;
    void displayPasskey(BluezQt::DevicePtr device, const QString &passkey, const QString &entered) override;
    void requestConfirmation(BluezQt::DevicePtr device, const QString &passkey, const BluezQt::Request<void> &request) override;

    Q_SIGNALS:
        void pinRequested(QString deviceName, const QString &pin);
    void confirmationRequested(QString deviceName, const QString &passkey, const VoidRequest *request);

private:
    bool i_fromDatabase;
    QString m_pin;
};
}
