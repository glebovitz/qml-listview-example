/*
 * Quickly - ES6 and Node.js-like environment for QML
 *
 * Copyright (C) 2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#ifndef PATH_H
#define PATH_H

#include "basemodule.h"

#include <QString>
#include <QVariantMap>
#include <QQmlEngine>

class Path : public BaseModule
{
    Q_OBJECT

    Q_PROPERTY(QString delimiter READ delimiter CONSTANT)

public:
    Path(QQmlEngine *engine) : BaseModule(engine) {}

    QString delimiter() const;

    Q_INVOKABLE QString basename(const QString &path, const QString &ext = "") const;
    Q_INVOKABLE QString dirname(const QString &path) const;
    Q_INVOKABLE QString extname(const QString &path) const;
    Q_INVOKABLE QString format(const QVariantMap &pathObject) const;
    Q_INVOKABLE QVariantMap parse(QString path) const;
    Q_INVOKABLE bool isAbsolute(const QString &path) const;

    static QObject *qmlSingleton(QQmlEngine *engine, QJSEngine *scriptEngine);
};

#endif // PATH_H
