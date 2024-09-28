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

#include "bluetooth.h"

Bluetooth::Bluetooth(QObject *parent)
    : QObject(parent)
    , m_manager(new BluezQt::Manager())
    , m_discovering(false)
{
    auto job = m_manager->init();

    connect(job, &BluezQt::InitManagerJob::result, this, [this](BluezQt::InitManagerJob *job) {
        if (job->error()) {
            qWarning() << "Error initializing the BluezQt Manager: " << job->errorText();
            emit errorOccurred(job->errorText());
            return;
        }

        // Set the discovery filter for all current Bluetooth adapters
        for (auto a : m_manager->adapters()) {
            auto adapter = a.get();

            setDiscoveryFilter(adapter->toSharedPtr());

            // Set the initial discovery state
            if (m_discovering != adapter->isDiscovering()) {
                setDiscovering(adapter->toSharedPtr(), m_discovering);
            }

            connect(adapter, &BluezQt::Adapter::discoveringChanged, this, &Bluetooth::slotDiscoveringChanged);
        }

        // Handle when an adapter is connected
        connect(m_manager, &BluezQt::Manager::adapterAdded, this, &Bluetooth::adapterAdded);
    });
    job->start();
}

Bluetooth::~Bluetooth()
{
    // Turn off discovering on adapters on exit
    if (m_discovering) {
        for (auto &adapter : m_manager->adapters()) {
            setDiscovering(adapter, false);
        }
    }
}

Bluetooth &Bluetooth::instance()
{
    static Bluetooth _instance;
    return _instance;
}

void Bluetooth::adapterAdded(BluezQt::AdapterPtr adapter)
{
    setDiscoveryFilter(adapter);

    connect(adapter.get(), &BluezQt::Adapter::discoveringChanged, this, &Bluetooth::slotDiscoveringChanged);
}

void Bluetooth::slotDiscoveringChanged(bool discovering)
{
    setDiscovering(discovering);
}

void Bluetooth::disable() const
{
    m_manager->setBluetoothBlocked(true);

    for (auto &adapter : m_manager->adapters()) {
        auto call = adapter.get()->setPowered(false);

        connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
            if (call->error()) {
                qWarning() << "Error turning off adapter" << adapter.get()->name() << ":" << call->error() << ":" << call->errorText();
                emit errorOccurred(call->errorText());
            }
        });
    }
}

void Bluetooth::enable() const
{
    m_manager->setBluetoothBlocked(false);

    for (auto &adapter : m_manager->adapters()) {
        auto call = adapter.get()->setPowered(true);

        connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
            if (call->error()) {
                qWarning() << "Error turning on adapter" << adapter.get()->name() << ":" << call->error() << ":" << call->errorText();
                emit errorOccurred(call->errorText());
            }
        });
    }
}

void Bluetooth::toggle() const
{
    if (m_manager->isBluetoothBlocked()) {
        enable();
    } else {
        disable();
    }
}

bool Bluetooth::discovering() const
{
    return m_discovering;
}

void Bluetooth::setDiscovering(bool discovering)
{
    if (m_discovering == discovering) {
        return;
    }

    m_discovering = discovering;
    emit discoveringChanged();

    for (auto &adapter : m_manager->adapters()) {
        setDiscovering(adapter, m_discovering);
    }
}

void Bluetooth::setDiscovering(BluezQt::AdapterPtr adapter, bool discovering) const
{
    // If the adapter is already in the desired state, do nothing
    if (adapter.get()->isDiscovering() == discovering) {
        return;
    }

    auto call = discovering ? adapter.get()->startDiscovery() : adapter.get()->stopDiscovery();

    connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
        if (call->error()) {
            qWarning() << "Error setting discovering on adapter '" << adapter.get()->name() << "': " << call->errorText();
            emit errorOccurred(call->errorText());
            return;
        }
    });
}

void Bluetooth::setDiscoveryFilter(BluezQt::AdapterPtr adapter) const
{
    QVariantMap filter;

    filter.insert("Discoverable", true);

    auto call = adapter.get()->setDiscoveryFilter(filter);

    connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
        if (call->error()) {
            qWarning() << "Error setting filter on adapter '" << adapter.get()->name() << "': " << call->errorText();
            emit errorOccurred(call->errorText());
        }
    });
}
