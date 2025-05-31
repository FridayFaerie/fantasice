pragma Singleton
import QtQuick 2.15
import Quickshell

import "./."

Singleton {
    id: root
    readonly property int imageWidth: 80

    // default tos when on ground
    readonly property var groundTos: {
        "standing-left": 0,
        "standing-right": 0,
        "walking-left": 0,
        "walking-right": 0
    }

    // Qt6 still on ECMA7... can't do spread operator on objects... :(
    function newTos(defaultObject, overrides) {
        var result = {}
        for (var key in defaultObject) {
            result[key] = defaultObject[key]; // Copy default values
        }
        for (var key in overrides) {
            result[key] = overrides[key];
        }
        return result;
    }

    readonly property list<Sprite> slist: [
        BasicSprite {
            name: "standing-left"
            frameCount: 1
            frameX: root.imageWidth * 1
            frameY: root.imageWidth * 0
            to: root.newTos(root.groundTos, {
              "standing-left": 100,
              "standing-right": 50,
              "walking-left": 50
            })
        },
        BasicSprite {
            name: "standing-right"
            frameCount: 1
            frameX: root.imageWidth * 1
            frameY: root.imageWidth * 1
            to: root.newTos(root.groundTos, {
              "standing-right": 100,
              "standing-left": 50,
              "walking-right": 50
            })
        },
        BasicSprite {
            name: "walking-left"
            frameCount: 4
            frameX: root.imageWidth * 0
            frameY: root.imageWidth * 0
            to: root.newTos(root.groundTos, {
                "standing-left": 50,
                "walking-left": 100
            })
        },
        BasicSprite {
            name: "walking-right"
            frameCount: 4
            frameX: root.imageWidth * 0
            frameY: root.imageWidth * 1
            to: root.newTos(root.groundTos, {
                "standing-right": 50,
                "walking-right": 100
            })
        }
    ]
}
