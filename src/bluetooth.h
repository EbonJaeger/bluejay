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
#include <BluezQt/InitManagerJob>
#include <BluezQt/Manager>
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

    Q_PROPERTY(bool discovering READ discovering WRITE setDiscovering NOTIFY discoveringChanged)

public:
    virtual ~Bluetooth();
    static Bluetooth &instance();
    static Bluetooth *create(QQmlEngine *engine, QJSEngine *)
    {
        engine->setObjectOwnership(&instance(), QQmlEngine::CppOwnership);
        return &instance();
    }

    /**
     * Disables Bluetooth on the system by turning on
     * rfkill and powering off all connected adapters.
     */
    Q_INVOKABLE void disable() const;

    /**
     * Enables Bluetooth on the system by turning off
     * rfkill and powering on all connected adapters.
     */
    Q_INVOKABLE void enable() const;

    /**
     * Turns Bluetooth on or off, depending on whether
     * Bluetooth is corrently on or off.
     *
     * If Bluetooth is currently disabled, it will be
     * turned on. Likewise, if Bluetooth is enabled,
     * it will be turned off.
     */
    Q_INVOKABLE void toggle() const;

    /**
     * Check whether any connected Bluetooth adapters
     * are in discovery mode.
     *
     * @returns True if an adapter is discovering
     */
    Q_INVOKABLE bool discovering() const;

    /**
     * @brief Set the discovering state.
     *
     * Iterates over all connected adapters, and sets their
     * discovering state accordingly.
     *
     * @param discovering Whether to enable discovery
     */
    Q_INVOKABLE void setDiscovering(bool discovering);

    /**
     * @brief Turn Bluez errors into a useable message.
     *
     * Turns Bluez error codes into message suitable for
     * displaying to the user.
     *
     * @param code The numerical error code
     */
    Q_INVOKABLE QString errorText(int code) const;

public Q_SLOTS:
    void adapterAdded(BluezQt::AdapterPtr adapter);
    void slotDiscoveringChanged(bool discovering);

Q_SIGNALS:
    /**
     * @brief Discovering state changed
     *
     * If a connected Bluetooth adapter's discovering state changes,
     * this signal will be emitted.
     */
    void discoveringChanged();

    /**
     * @brief Emit that an error occurred
     *
     * When an error occurs, we want to show it in the UI.
     * Since we only want to display error text, we don't need
     * the entirity of BluezQt's error/PendingCall class.
     */
    void errorOccurred(QString errorText) const;

private:
    BluezQt::Manager *m_manager;
    bool m_discovering;

private:
    explicit Bluetooth(QObject *parent = nullptr);

    /**
     * @brief Set discovering state.
     *
     * Set the discovering state of a Bluetooth adapter.
     *
     * @param adapter The adapter to set the state for
     * @param discovering Whether to start or stop discovering
     */
    void setDiscovering(BluezQt::AdapterPtr adapter, bool discovering) const;

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
