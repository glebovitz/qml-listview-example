import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import "model.js" as Model

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Navigator {
        id: navigator
    }

    Rectangle {
        width: parent.width; height: (parent.height * 2) / 3
        color: "lightGrey"

        Text {
            id: textid
            text: "yahoo"
        }

        Component {
            id: horzDelegate

            Rectangle {
                id: rect
                width: parent.parent.width
                height: 50
                Text {
                    text : name
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log(name + " clicked");
                    }
                }
               Component.onCompleted: {
//                   console.log("width", width, "index:", index)
                }
            }
        }


        Component {
            id: vertDelegate

            ListView {
                id: vertView
                property var peopleList
                width: parent.parent.width
                height: 50;
                spacing: 20
                model: ListModel {
                    id:peopleModel
                }
                orientation: ListView.Horizontal
                delegate: horzDelegate
                Component.onCompleted: {
                    Model.mystuff.setUp()
                    if (typeof Model.people[index] != 'undefined') {
                        var list = Model.people[index].list
                        for (var person in list) {
                            peopleModel.append(list[person])
//                            console.log("person", list[person], peopleModel.count)
                        }
                    }
                }

                Rectangle {
                    id:vertRect
                    width: parent.width
                    anchors.bottom: parent.bottom
                    height:20
                    color:"Red"
                }
                MouseArea {
                    anchors.fill:parent
                    onClicked: {
                        vertRect.visible = ! vertRect.visible
                    }
                }
            }
        }

        ListView {
            id:listView
            anchors.fill: parent
            model: Model.people.length
            spacing: 20
            cacheBuffer: 200 // in pixels
            delegate: vertDelegate

            Request {
                id: jsonRequest

            }
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
