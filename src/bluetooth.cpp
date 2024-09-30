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
                emit errorOccurred(errorText(call->error()));
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
                emit errorOccurred(errorText(call->error()));
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
    if (!m_manager->isBluetoothOperational() || m_manager->isBluetoothBlocked()) {
        return;
    }

    // If the adapter is already in the desired state, do nothing
    if (adapter.get()->isDiscovering() == discovering) {
        return;
    }

    auto call = discovering ? adapter.get()->startDiscovery() : adapter.get()->stopDiscovery();

    connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
        if (call->error()) {
            qWarning() << "Error setting discovering on adapter '" << adapter.get()->name() << "': " << call->errorText();
            emit errorOccurred(errorText(call->error()));
            return;
        }
    });
}

void Bluetooth::setDiscoveryFilter(BluezQt::AdapterPtr adapter) const
{
    if (!m_manager->isBluetoothOperational() || m_manager->isBluetoothBlocked()) {
        return;
    }

    QVariantMap filter;

    filter.insert("Discoverable", true);

    auto call = adapter.get()->setDiscoveryFilter(filter);

    connect(call, &BluezQt::PendingCall::finished, this, [this, adapter](BluezQt::PendingCall *call) {
        if (call->error()) {
            qWarning() << "Error setting filter on adapter '" << adapter.get()->name() << "': " << call->errorText();
            emit errorOccurred(errorText(call->error()));
        }
    });
}

QString Bluetooth::errorText(int code) const
{
    QString message;

    switch (code) {
        case BluezQt::PendingCall::Error::NotReady:
            message = tr("Device is not ready");
            break;
        case BluezQt::PendingCall::Error::Failed:
            message = tr("Connection failed");
            break;
        case BluezQt::PendingCall::Error::Rejected:
            message = tr("Connection rejected");
            break;
        case BluezQt::PendingCall::Error::Canceled:
            message = tr("Connection canceled");
            break;
        case BluezQt::PendingCall::Error::InvalidArguments:
            message = tr("Invalid arguments");
            break;
        case BluezQt::PendingCall::Error::AlreadyExists:
            message = tr("Already exists");
            break;
        case BluezQt::PendingCall::Error::DoesNotExist:
            message = tr("Does not exist");
            break;
        case BluezQt::PendingCall::Error::InProgress:
            message = tr("Already in progress");
            break;
        case BluezQt::PendingCall::Error::NotInProgress:
            message = tr("Not in progress");
            break;
        case BluezQt::PendingCall::Error::AlreadyConnected:
            message = tr("Already connected");
            break;
        case BluezQt::PendingCall::Error::ConnectFailed:
            message = tr("Connection failed");
            break;
        case BluezQt::PendingCall::Error::NotConnected:
            message = tr("Not connected");
            break;
        case BluezQt::PendingCall::Error::NotSupported:
            message = tr("Action not supported");
            break;
        case BluezQt::PendingCall::Error::NotAuthorized:
            message = tr("Not authorized");
            break;
        case BluezQt::PendingCall::Error::AuthenticationCanceled:
            message = tr("Authentication canceled");
            break;
        case BluezQt::PendingCall::Error::AuthenticationFailed:
            message = tr("Authentication failed");
            break;
        case BluezQt::PendingCall::Error::AuthenticationRejected:
            message = tr("Authentication rejected");
            break;
        case BluezQt::PendingCall::Error::AuthenticationTimeout:
            message = tr("Authentication timed out");
            break;
        case BluezQt::PendingCall::Error::ConnectionAttemptFailed:
            message = tr("Connection failed");
            break;
        case BluezQt::PendingCall::Error::InvalidLength:
            message = tr("Invalid packet length");
            break;
        case BluezQt::PendingCall::Error::NotPermitted:
            message = tr("Action not permitted");
            break;
        case BluezQt::PendingCall::Error::DBusError:
            message = tr("DBus error");
            break;
        case BluezQt::PendingCall::Error::InternalError:
            message = tr("Internal error");
            break;
        default:
            message = tr("Unknown error");
            break;
    }

    //: Error message for in-app notifications. The intended format is, for example, "Error 2: Connection failed"
    return tr("Error %1: %2").arg(code).arg(message);
}
