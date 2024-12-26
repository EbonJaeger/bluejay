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

#include <BluezQt/InitManagerJob>
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#if KI18N_VERSION >= QT_VERSION_CHECK(6, 8, 0)
#include <KLocalizedQmlContext>
#endif

#include "bluejay-version.h"

using namespace Qt::Literals::StringLiterals;

void qml_register_types_io_github_ebonjaeger_bluejay();

int main(int argc, char *argv[])
{
    QIcon::setFallbackThemeName(QStringLiteral("breeze"));

    QApplication app(argc, argv);

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }

    KLocalizedString::setApplicationDomain(QByteArrayLiteral("bluejay"));

    QGuiApplication::setOrganizationName(QStringLiteral("EbonJaeger"));

    KAboutData about(QStringLiteral("bluejay"),
                     i18n("Bluejay"),
                     QStringLiteral(BLUEJAY_VERSION_STRING),
                     i18n("Bluetooth device manager"),
                     KAboutLicense::Unknown,
                     i18n("© Evan Maddock"));
    about.setHomepage(QStringLiteral("https://github.com/EbonJaeger/bluejay"));
    about.setBugAddress(QByteArray("https://github.com/EbonJaeger/bluejay/issues"));
    about.setDesktopFileName(QStringLiteral("io.github.ebonjaeger.bluejay"));
    about.addAuthor(QStringLiteral("Evan Maddock"),
                    i18n("Maintainer"),
                    QStringLiteral("maddock.evan@vivaldi.net"),
                    QStringLiteral("https://github.com/EbonJaeger"));

    KAboutData::setApplicationData(about);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("io.github.ebonjaeger.bluejay")));
    QGuiApplication::setDesktopFileName(QStringLiteral("io.github.ebonjaeger.bluejay"));

    qml_register_types_io_github_ebonjaeger_bluejay();

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            QCoreApplication::exit(1);
        },
        Qt::QueuedConnection);

#if KI18N_VERSION >= QT_VERSION_CHECK(6, 8, 0)
    engine.rootContext()->setContextObject(new KLocalizedQmlContext(&engine));
#else
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
#endif

    engine.loadFromModule("io.github.ebonjaeger.bluejay", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
