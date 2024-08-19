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

#include "Bluetooth.h"

Bluetooth::Bluetooth(QObject * parent)
: QObject(parent)
, m_manager(new BluezQt::Manager())
{
    auto job = m_manager->init();

    connect(job, &BluezQt::InitManagerJob::result, this, [this](BluezQt::InitManagerJob *job) {
        if (job->error()) {
            qWarning() << "There was an error initing the BluezQt Manager: " << job->errorText();
            emit errorOccurred(job->errorText());
            return;
        }

        // Set the discovery filter for all current Bluetooth adapters
        for (auto adapter : m_manager->adapters()) {
            setDiscoveryFilter(adapter);
        }

        // Handle when an adapter is connected
        connect(m_manager, &BluezQt::Manager::adapterAdded, this, &Bluetooth::onAdapterAdded);
    });
    job->start();
}

Bluetooth::~Bluetooth()
{}

Bluetooth &Bluetooth::instance()
{
    static Bluetooth _instance;
    return _instance;
}

void Bluetooth::onAdapterAdded(BluezQt::AdapterPtr adapter)
{
    setDiscoveryFilter(adapter);
}

void Bluetooth::setDiscoveryFilter(BluezQt::AdapterPtr adapter) const
{
    QVariantMap filter;

    filter.insert("Discoverable", true);

    auto call = adapter.get()->setDiscoveryFilter(filter);

    connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call){
        if (call->error()) {
            qWarning() << "Unable to set filter on adapter '" << adapter.get()->name() << "': " << call->errorText();
            emit errorOccurred(call->errorText());
        }
    });
}
