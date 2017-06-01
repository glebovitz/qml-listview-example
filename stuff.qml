import QtQuick 2.7

ListModel {
    id: myModel

    ListElement {
        list : [
            ListElement { name:"Gregg"; age:"59" },
            ListElement { name:"John"; age:"18" },
            ListElement { name:"charley"; age:"54" }
        ]
    }
    ListElement {
        llst : [
            ListElement{ name:"Tom"; age:"25" },
            ListElement{ name:"Dick"; age:"47" },
            ListElement{ name:"Harry"; age:"33" }
        ]
    }
    ListElement {
        list : [
            ListElement{ name:"Sally"; age:"25" },
            ListElement{ name:"Jane"; age:"47" },
            ListElement{ name:"Richard"; age:"33" }
        ]
    }
    ListElement {
        list : [
            ListElement{ name:"Alex"; age:"59" },
            ListElement{ name:"Bill"; age:"18" },
            ListElement{ name:"Shirley"; age:"54" }
        ]
    }
    ListElement {
        list : [
            ListElement{ name:"Marcie"; age:"25" },
            ListElement{ name:"Steve"; age:"47" },
            ListElement{ name:"Nicky"; age:"33" }
        ]
    }
    ListElement {
        list : [
            ListElement{ name:"Oscar"; age:"25" },
            ListElement{ name:"Foster"; age:"47" },
            ListElement{ name:"Louise"; age:"33" }
        ]
    }
}
