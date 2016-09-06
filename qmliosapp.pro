message("qmliosapp.pro")
QT += qml quick

CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

ios {
QMAKE_TARGET_BUNDLE_PREFIX = "net.lebovitz"
}

# Default rules for deployment.
include(deployment.pri)
include(vendor/vendor.pri)
