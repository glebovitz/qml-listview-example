import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import "model.js" as Model

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Rectangle {
        width: parent.width; height: (parent.height * 2) / 3
        color: "lightGrey"

        ListModel {
            id: colorsModel
            ListElement {
                colorCode: "red"
            }
            ListElement {
                colorCode: "green"
            }
            ListElement {
                colorCode: "blue"
            }
            ListElement {
                colorCode: "orange"
            }
            ListElement {
                colorCode: "white"
            }
            ListElement {
                colorCode: "purple"
            }
            ListElement {
                colorCode: "gray"
            }
            ListElement {
                colorCode: "yellow"
            }
            ListElement {
                colorCode: "purple"
            }
        }

        Component {
            id: horzDelegate

            Rectangle {
                id: rect
                property int rowIndex: 0
                color: "lightblue"
                width: parent.width
                height: 50

                Text { text: index }
                Text { text: rowIndex }


                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log(colorCode + " clicked");
                    }
                }
               Component.onCompleted: {
                   var row = parent.parent.parent.rowIndex
                   if (typeof row != 'undefined') {
                       this.rowIndex = row
                   }
                }
            }
        }

        Component {
            id: vertDelegate

            ListView {
                width: parent.width;
                height: 50;
                spacing: 20
                model: colorsModel
                orientation: ListView.Horizontal
                delegate: horzDelegate
                Component.onCompleted: {
                   parent.rowIndex = index
//                    console.log(rowIndex)
                }
            }
        }

        ListView {
            id:listView
            anchors.fill: parent
            model: 30
            spacing: 20
            cacheBuffer: 200 // in pixels
            delegate: vertDelegate
        }
    }

    //    footer: TabBar {
    //        id: tabBar
    //        currentIndex: swipeView.currentIndex
    //        TabButton {
    //            text: qsTr("First")
    //        }
    //        TabButton {
    //            text: qsTr("Second")
    //        }
    //    }
}
