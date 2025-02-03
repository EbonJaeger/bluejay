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

#include <BluezQt/Adapter>
#include <BluezQt/InitManagerJob>
#include <BluezQt/Manager>
#include <BluezQt/PendingCall>
#include <BluezQt/Services>

#include "bluetooth.h"

Bluetooth::Bluetooth(QObject *parent)
    : QObject(parent)
    , m_agent(new BtAgent(this))
    , m_manager(new BluezQt::Manager())
    , m_blocked(false)
    , m_discovering(false)
    , m_enabled(true)
{
    const auto job = m_manager->init();

    connect(job, &BluezQt::InitManagerJob::result, this, [this](const BluezQt::InitManagerJob *j) {
        if (j->error()) {
            qWarning() << "Error initializing the BluezQt Manager: " << j->errorText();
            Q_EMIT errorOccurred(j->errorText());
            return;
        }

        m_blocked = m_manager->isBluetoothBlocked();
        m_enabled = m_manager->isBluetoothOperational();

        // Make sure to register our Agent
        bluetoothOperationalChanged(m_enabled);
        connect(m_manager, &BluezQt::Manager::bluetoothOperationalChanged, this, &Bluetooth::bluetoothOperationalChanged);

        // Set the discovery filter for all current Bluetooth adapters
        for (const auto &adapter : m_manager->adapters()) {
            setDiscoveryFilter(adapter);

            // Set the initial discovery state
            if (m_discovering != adapter->isDiscovering()) {
                setDiscovering(adapter->toSharedPtr(), m_discovering);
            }

            connect(adapter.get(), &BluezQt::Adapter::discoveringChanged, this, &Bluetooth::slotDiscoveringChanged);
        }

        // Connect signals
        connect(m_manager, &BluezQt::Manager::adapterAdded, this, &Bluetooth::adapterAdded);
        connect(m_manager, &BluezQt::Manager::bluetoothBlockedChanged, this, &Bluetooth::bluetoothBlockedChanged);
        connect(m_manager, &BluezQt::Manager::deviceRemoved, this, &Bluetooth::onDeviceRemoved);
    });
    job->start();
}

Bluetooth::~Bluetooth()
{
    // Turn off discovering on adapters on exit
    if (m_discovering) {
        for (const auto &adapter : m_manager->adapters()) {
            setDiscovering(adapter, false);
        }
    }
}

Bluetooth &Bluetooth::instance()
{
    static Bluetooth _instance;
    return _instance;
}

void Bluetooth::adapterAdded(const BluezQt::AdapterPtr &adapter)
{
    setDiscoveryFilter(adapter);
    connect(adapter.get(), &BluezQt::Adapter::discoveringChanged, this, &Bluetooth::slotDiscoveringChanged);
}

void Bluetooth::bluetoothBlockedChanged(const bool blocked)
{
    if (m_blocked == blocked) {
        return;
    }

    m_blocked = blocked;
    Q_EMIT blockedChanged();
}

void Bluetooth::bluetoothOperationalChanged(const bool operational)
{
    if (operational) {
        m_manager->registerAgent(m_agent);
    } else {
        BluezQt::Manager::startService();
    }

    m_enabled = operational;
    Q_EMIT enabledChanged();
}

void Bluetooth::slotDiscoveringChanged(const bool discovering)
{
    setDiscovering(discovering);
}

void Bluetooth::onDeviceRemoved(const BluezQt::DevicePtr device) const
{
    Q_EMIT deviceRemoved(device->address());
}

BtAgent *Bluetooth::agent() const
{
    return m_agent;
}

bool Bluetooth::blocked() const
{
    return m_blocked;
}

void Bluetooth::disable() const
{
    m_manager->setBluetoothBlocked(true);

    for (const auto &adapter : m_manager->adapters()) {
        adapter->setPowered(false);
    }
}

void Bluetooth::enable() const
{
    m_manager->setBluetoothBlocked(false);

    for (const auto &adapter : m_manager->adapters()) {
        adapter->setPowered(true);
    }
}

bool Bluetooth::enabled() const
{
    return m_enabled;
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

void Bluetooth::setDiscovering(const bool discovering)
{
    if (m_discovering == discovering) {
        return;
    }

    m_discovering = discovering;
    Q_EMIT discoveringChanged();

    for (const auto &adapter : m_manager->adapters()) {
        setDiscovering(adapter, m_discovering);
    }
}

void Bluetooth::setDiscovering(const BluezQt::AdapterPtr &adapter, const bool discovering) const
{
    if (!m_manager->isBluetoothOperational() || m_manager->isBluetoothBlocked()) {
        return;
    }

    // If the adapter is already in the desired state, do nothing
    if (adapter->isDiscovering() == discovering) {
        return;
    }

    discovering ? adapter->startDiscovery() : adapter->stopDiscovery();
}

void Bluetooth::setDiscoveryFilter(const BluezQt::AdapterPtr &adapter) const
{
    if (!m_manager->isBluetoothOperational() || m_manager->isBluetoothBlocked()) {
        return;
    }

    QVariantMap filter;

    filter.insert(QLatin1String("Discoverable"), true);
    adapter->setDiscoveryFilter(filter);
}

QString Bluetooth::deviceTypeToString(const BluezQt::Device::Type type, const QStringList &uuids)
{
    switch (type) {
    case BluezQt::Device::Phone:
        //: Used to show the type of the Bluetooth device
        return tr("Phone");
    case BluezQt::Device::Modem:
        //: Used to show the type of the Bluetooth device
        return tr("Modem");
    case BluezQt::Device::Computer:
        //: Used to show the type of the Bluetooth device
        return tr("Computer");
    case BluezQt::Device::Network:
        //: Used to show the type of the Bluetooth device
        return tr("Network");
    case BluezQt::Device::Headset:
        //: Used to show the type of the Bluetooth device
        return tr("Headset");
    case BluezQt::Device::Headphones:
        //: Used to show the type of the Bluetooth device
        return tr("Headphones");
    case BluezQt::Device::AudioVideo:
        //: Used to show the type of the Bluetooth device
        return tr("Multimedia");
    case BluezQt::Device::Keyboard:
        //: Used to show the type of the Bluetooth device
        return tr("Keyboard");
    case BluezQt::Device::Mouse:
        //: Used to show the type of the Bluetooth device
        return tr("Mouse");
    case BluezQt::Device::Joypad:
        //: Used to show the type of the Bluetooth device
        return tr("Joypad");
    case BluezQt::Device::Tablet:
        //: Used to show the type of the Bluetooth device
        return tr("Tablet");
    case BluezQt::Device::Peripheral:
        //: Used to show the type of the Bluetooth device
        return tr("Peripheral");
    case BluezQt::Device::Camera:
        //: Used to show the type of the Bluetooth device
        return tr("Camera");
    case BluezQt::Device::Printer:
        //: Used to show the type of the Bluetooth device
        return tr("Printer");
    case BluezQt::Device::Imaging:
        //: Used to show the type of the Bluetooth device
        return tr("Imaging");
    case BluezQt::Device::Wearable:
        //: Used to show the type of the Bluetooth device
        return tr("Wearable");
    case BluezQt::Device::Toy:
        //: Used to show the type of the Bluetooth device
        return tr("Toy");
    case BluezQt::Device::Health:
        //: Used to show the type of the Bluetooth device
        return tr("Health");
    default:
        QStringList profiles;

        if (uuids.contains(BluezQt::Services::ObexFileTransfer)) {
            profiles.append(tr("File transfer"));
        }

        if (uuids.contains(BluezQt::Services::ObexObjectPush)) {
            profiles.append(tr("Send file"));
        }

        if (uuids.contains(BluezQt::Services::HumanInterfaceDevice)) {
            //: Used to show the type of the Bluetooth device
            profiles.append(tr("Input"));
        }

        if (uuids.contains(BluezQt::Services::AdvancedAudioDistribution)) {
            //: Used to show the type of the Bluetooth device
            profiles.append(tr("Audio"));
        }

        if (uuids.contains(BluezQt::Services::Nap)) {
            //: Used to show the type of the Bluetooth device
            profiles.append(tr("Network"));
        }

        if (profiles.empty()) {
            //: Used to show the type of the Bluetooth device
            profiles.append(tr("Other"));
        }

        return profiles.join(QStringLiteral(", "));
    }
}

void Bluetooth::setDeviceTrusted(const QString &address, bool trusted) const
{
    const auto device = m_manager->deviceForAddress(address);

    if (!device) {
        Q_EMIT errorOccurred(tr("Could not find device"));
        return;
    }

    device->setTrusted(trusted);
}

void Bluetooth::setDeviceBlocked(const QString &address, bool blocked) const
{
    const auto device = m_manager->deviceForAddress(address);

    if (!device) {
        Q_EMIT errorOccurred(tr("Could not find device"));
        return;
    }

    device->setBlocked(blocked);
}

QString Bluetooth::errorText(const int code)
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
