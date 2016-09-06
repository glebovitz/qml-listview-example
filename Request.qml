import QtQuick 2.7
import Quickly 0.1
import "app.js" as App

QtObject {
    id: jaonRequest

    signal requestReady(var request);
    signal requestFailed(var request);
}
