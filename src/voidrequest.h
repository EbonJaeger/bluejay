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

#include <BluezQt/Request>
#include <QQmlEngine>

/**
 * @class Bluejay::VoidRequest voidrequest.h <Bluejay/VoidRequest>
 *
 * Wrapper class for a BluezQt void request for use with QML.
 *
 * @see BluezQt::Request
 */
class VoidRequest : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("This is a wrapper class for BluezQt::Request<void>")

public:
    /**
     * Creates a new VoidRequest object.
     */
    explicit VoidRequest(const BluezQt::Request<void> &request, QObject *parent = nullptr);

    /**
     * Destroys a VoidRequest object.
     */
    virtual ~VoidRequest();

    /**
     * Accepts the request.
     *
     * This method should be called to send a reply to indicate
     * the request was accepted.
     */
    Q_INVOKABLE void accept() const;

    /**
     * Cancels the request.
     *
     * This method should be called to send a reply to indicate
     * the request was canceled.
     */
    Q_INVOKABLE void cancel() const;

    /**
     * Rejects the request.
     *
     * This method should be called to send a reply to indicate
     * the request was rejected.
     */
    Q_INVOKABLE void reject() const;

private:
    BluezQt::Request<void> m_request;
};
