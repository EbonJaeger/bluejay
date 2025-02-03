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

#include "btagent.h"
#include "voidrequest.h"

#include <QDBusObjectPath>
#include <QFile>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QXmlStreamReader>

BtAgent::BtAgent(QObject *parent)
    : Agent(parent)
    , i_fromDatabase(false)
{
}

QString BtAgent::pin() const
{
    return m_pin;
}

void BtAgent::setPin(const QString &pin)
{
    m_pin = pin;
    i_fromDatabase = false;
}

QString BtAgent::generatePin(const BluezQt::DevicePtr &device)
{
    i_fromDatabase = false;
    m_pin = QString::number(QRandomGenerator::global()->bounded(RAND_MAX)).left(6);

    const auto databasePath = QStandardPaths::locate(QStandardPaths::AppLocalDataLocation, QStringLiteral("pin-code-database.xml"));
    QFile file(databasePath);

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Unable to open pin-code-database.xml";
        return m_pin;
    }

    QXmlStreamReader reader(&file);
    auto type = BluezQt::Device::typeToString(device->type());

    // Use the same type for audiovideo and audio-only devices
    if (type == QLatin1String("audiovideo")) {
        type = QStringLiteral("audio");
    }

    // Read each entry in the PIN database, and apply any special cases as necessary
    while (!reader.atEnd()) {
        reader.readNext();

        if (reader.name() != QLatin1String("device")) {
            continue;
        }

        auto attrs = reader.attributes();

        // Skip entry if the type doesn't match
        if (attrs.hasAttribute(QLatin1String("type")) && attrs.value(QLatin1String("device")) != QLatin1String("any")) {
            if (type != attrs.value(QLatin1String("type")).toString()) {
                continue;
            }
        }

        // Skip entry if the device OUI doesn't match
        if (attrs.hasAttribute(QLatin1String("oui")) && !device->address().startsWith(attrs.value(QLatin1String("oui")))) {
            continue;
        }

        // Skip entry if the device name doesn't match
        if (attrs.hasAttribute(QLatin1String("name")) && !device->name().contains(attrs.value(QLatin1String("name")))) {
            continue;
        }

        // Read the PIN from the database
        m_pin = attrs.value(QLatin1String("pin")).toString();
        i_fromDatabase = true;

        // Generate a new PIN if the device only supports a maximum number of characters
        if (m_pin.startsWith(QStringLiteral("max:"))) {
            const auto num = m_pin.right(m_pin.length() - 4).toInt();
            m_pin = QString::number(QRandomGenerator::global()->bounded(RAND_MAX)).left(num);
        }

        break;
    }

    qDebug() << "PIN: " << m_pin;
    return m_pin;
}

QDBusObjectPath BtAgent::objectPath() const
{
    return QDBusObjectPath(QStringLiteral("/agent"));
}

void BtAgent::requestPinCode(const BluezQt::DevicePtr device, const BluezQt::Request<QString> &request)
{
    qDebug() << "AGENT-RequestPinCode" << device->ubi();
    Q_EMIT pinRequested(device->name(), m_pin);
    request.accept(m_pin);
}

void BtAgent::displayPinCode(const BluezQt::DevicePtr device, const QString &pinCode)
{
    qDebug() << "AGENT-DisplayPinCode" << device->ubi() << pinCode;
    Q_EMIT pinRequested(device->name(), pinCode);
}

void BtAgent::requestPasskey(const BluezQt::DevicePtr device, const BluezQt::Request<quint32> &request)
{
    const auto pin = generatePin(device);
    qDebug() << "AGENT-RequestPasskey" << device->ubi() << pin;
    request.accept(pin.toUInt());
}

void BtAgent::displayPasskey(const BluezQt::DevicePtr device, const QString &passkey, const QString &entered)
{
    Q_UNUSED(entered);

    qDebug() << "AGENT-DisplayPasskey" << device->ubi() << passkey;
    Q_EMIT pinRequested(device->name(), passkey);
}

void BtAgent::requestConfirmation(const BluezQt::DevicePtr device, const QString &passkey, const BluezQt::Request<void> &request)
{
    qDebug() << "AGENT-RequestConfirmation" << device->ubi() << passkey;
    const auto v = new VoidRequest(request);
    Q_EMIT confirmationRequested(device->name(), passkey, v);
}

#include "moc_btagent.cpp"
