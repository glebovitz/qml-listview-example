message("quickly.pri")
include(qmlify.pri)

QT += core-private qml qml-private

HEADERS += \
           $$PWD/nodejs/filesystem.h \
           $$PWD/nodejs/path.h \
           $$PWD/nodejs/process.h \
           $$PWD/nodejs/basemodule.h \
    $$PWD/quicklyplugin.h

SOURCES += \
           $$PWD/nodejs/filesystem.cpp \
           $$PWD/nodejs/path.cpp \
           $$PWD/nodejs/process.cpp \
           $$PWD/nodejs/basemodule.cpp \
    $$PWD/quicklyplugin.cpp

RESOURCES += $$PWD/resources.qrc
