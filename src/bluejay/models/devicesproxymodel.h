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

#include <BluezQt/DevicesModel>
#include <QQmlEngine>
#include <QSortFilterProxyModel>

class DevicesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum AdditionalRoles {
        SectionRole = BluezQt::DevicesModel::LastRole + 10,
        DeviceFullNameRole = BluezQt::DevicesModel::LastRole + 11,
    };

    DevicesProxyModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE QString adapterHciString(const QString &ubi) const;

private:
    bool duplicateIndexAddress(const QModelIndex &index) const;
};
