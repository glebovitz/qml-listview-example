import QtQuick 2.0
import QtPositioning 5.2
import QtLocation 5.3

QtObject {
    id:navigator

    Plugin {
        id: geocodePlugin
        name: "osm"
        //specify plugin parameters as necessary
        //PluginParameter {...}
        //PluginParameter {...}
        //...
    }

    GeocodeModel {
        id: geoModel
        plugin: geocodePlugin
        autoUpdate: false
    }



    PositionSource {
        id: positionSource
        property variant success : null
        property variant error : null

        onPositionChanged: {
            if (typeof success === "function") {
                success(position)
                success = null
            }
        }

        onSourceErrorChanged: {
            if (sourceError == PositionSource.NoError)
                return

            if (typeof error === "function") {
                error(position)
                error = null
            }

            console.log("Source error: " + sourceError)
            activityText.fadeOut = true
            stop()
        }

        onUpdateTimeout: {
            activityText.fadeOut = true
        }
    }

    QtObject {
        id:geolocation
        function getgeolocation (success, error) {
            if (typeof success === "function") {
                navigator.positionSource.success = success
            }
            if (typeof error === "function") {
                navigator.positionSource.error = error
            }
            navigator.positionSource.update()
        }
    }
}
