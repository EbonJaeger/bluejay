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

#include <QQmlEngine>

#include <BluezQt/Adapter>
#include <BluezQt/Manager>
#include <BluezQt/InitManagerJob>
#include <BluezQt/PendingCall>

/**
 * @class Bluetooth
 *
 * A singleton class to act as a bridge between QML objects and
 * BluezQt in C++.
 */
class Bluetooth : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    virtual ~Bluetooth();
    static Bluetooth &instance();
    static Bluetooth *create(QQmlEngine *engine, QJSEngine *)
    {
        engine->setObjectOwnership(&instance(), QQmlEngine::CppOwnership);
        return &instance();
    }

public Q_SLOTS:
    void onAdapterAdded(BluezQt::AdapterPtr adapter);

Q_SIGNALS:
    /**
     * @brief Emit that an error occurred
     *
     * When an error occurs, we want to show it in the UI.
     * Since we only want to display error text, we don't need
     * the entirity of BluezQt's error/PendingCall class.
     */
    void errorOccurred(QString errorText) const;

private:
    BluezQt::Manager * m_manager;

private:
    explicit Bluetooth(QObject * parent = nullptr);

    /**
     * @brief Set the discovery filter.
     *
     * When showing Bluetooth devices in the UI, we only care about
     * devices that can be paired and connected to. This sets the
     * filter on the given adapter to only show discoverable
     * devices.
     *
     * @param adapter The Bluetooth adapater
     */
    void setDiscoveryFilter(BluezQt::AdapterPtr adapter) const;
};
