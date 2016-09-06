/*
 * Quickly - ES6 and Node.js-like environment for QML
 *
 * Copyright (C) 2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#include "quicklyplugin.h"

#include <QtQml>
#include <QtDebug>

#include "nodejs/filesystem.h"
#include "nodejs/path.h"

void QuicklyPlugin::registerTypes(const char *uri)
{
    // @uri Quickly
    qDebug() << "Registering singletons...";
    Q_ASSERT(uri == QStringLiteral("Quickly"));

    qmlRegisterSingletonType<Filesystem>(uri, 0, 1, "Filesystem", Filesystem::qmlSingleton);
    qmlRegisterSingletonType<Path>(uri, 0, 1, "Paths", Path::qmlSingleton);
}
