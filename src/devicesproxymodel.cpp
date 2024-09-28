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

#include "devicesproxymodel.h"

DevicesProxyModel::DevicesProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    sort(0, Qt::DescendingOrder);
}

QHash<int, QByteArray> DevicesProxyModel::roleNames() const
{
    auto roles = QSortFilterProxyModel::roleNames();
    roles[SectionRole] = QByteArrayLiteral("Section");
    roles[DeviceFullNameRole] = QByteArrayLiteral("DeviceFullName");

    return roles;
}

QVariant DevicesProxyModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case SectionRole:
        if (index.data(BluezQt::DevicesModel::ConnectedRole).toBool()) {
            return QStringLiteral("Connected");
        }

        return QStringLiteral("Available");
    case DeviceFullNameRole:
        if (!duplicateIndexAddress(index)) {
            const auto &name = QSortFilterProxyModel::data(index, BluezQt::DevicesModel::NameRole).toString();
            const auto &ubi = QSortFilterProxyModel::data(index, BluezQt::DevicesModel::UbiRole).toString();
            const auto &hci = adapterHciString(ubi);

            if (!hci.isEmpty()) {
                return QStringLiteral("%1 - %2").arg(name, hci);
            }
        }

        return QSortFilterProxyModel::data(index, BluezQt::DevicesModel::NameRole);
    default:
        return QSortFilterProxyModel::data(index, role);
    }
}

bool DevicesProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    auto leftPaired = left.data(BluezQt::DevicesModel::PairedRole).toBool();
    auto rightPaired = left.data(BluezQt::DevicesModel::PairedRole).toBool();
    auto leftTrusted = left.data(BluezQt::DevicesModel::TrustedRole).toBool();
    auto rightTrusted = left.data(BluezQt::DevicesModel::TrustedRole).toBool();

    // Paired and trusted (thus setup) devices first
    auto leftSetup = leftPaired || leftTrusted;
    auto rightSetup = rightPaired || rightTrusted;

    if (leftSetup != rightSetup) {
        if (leftSetup) {
            return false;
        } else {
            return true;
        }
    }

    // Then connected devices
    auto leftConnected = left.data(BluezQt::DevicesModel::ConnectedRole).toBool();
    auto rightConnected = right.data(BluezQt::DevicesModel::ConnectedRole).toBool();

    if (leftConnected != rightConnected) {
        if (leftConnected) {
            return false;
        } else {
            return true;
        }
    }

    // All else fails, sort alphabetically
    const auto &leftName = left.data(BluezQt::DevicesModel::NameRole).toString();
    const auto &rightName = right.data(BluezQt::DevicesModel::NameRole).toString();

    return QString::localeAwareCompare(leftName, rightName) > 0;
}

// bool DevicesProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
//{
//     const auto index = sourceModel()->index(source_row, 0, source_parent);
//
//     // Only show paired and connected devices
//     return index.data(BluezQt::DevicesModel::PairedRole).toBool() ||
//            index.data(BluezQt::DevicesModel::ConnectedRole).toBool();
// }

/**
 * @brief DevicesProxyModel::adapterHciString
 * Retrieves the HCI string portion of a device UBI.
 *
 * @param ubi the UBI of the Bluetooth device
 * @return "hciX" part from UBI "/org/bluez/hciX/dev_xx_xx_xx_xx_xx_xx"
 */
QString DevicesProxyModel::adapterHciString(const QString &ubi) const
{
    auto startIndex = ubi.indexOf(QLatin1String("/hci")) + 1;

    if (startIndex < 1) {
        return {};
    }

    auto endIndex = ubi.indexOf(QLatin1Char('/'), startIndex);

    if (endIndex == -1) {
        return ubi.mid(startIndex);
    }

    return ubi.mid(startIndex, endIndex - startIndex);
}

bool DevicesProxyModel::duplicateIndexAddress(const QModelIndex &idx) const
{
    const auto &list = match(index(0, 0), //
                             BluezQt::DevicesModel::AddressRole,
                             idx.data(BluezQt::DevicesModel::AddressRole).toString(),
                             2,
                             Qt::MatchExactly);

    return list.size() > 1;
}

#include "moc_devicesproxymodel.cpp"
