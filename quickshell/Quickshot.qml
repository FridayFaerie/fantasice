import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: display
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: screen.width
    implicitHeight: screen.height
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function createPathMove(x, y) {
        var move = Qt.createQmlObject('import QtQuick;PathMove{}', shapePath);
        move.x = x;
        move.y = y;
        return move;
    }
    function createPathLine(x, y) {
        var line = Qt.createQmlObject('import QtQuick;PathLine{}', shapePath);
        line.x = x;
        line.y = y;
        return line;
    }
    function cropImage() {
        var drawCommands = "path 'M " + pathPoints[0].x + "," + pathPoints[0].y;
        for (var i = 1; i < pathPoints.length; i++) {
            drawCommands += " L " + pathPoints[i].x + "," + pathPoints[i].y;
        }
        drawCommands += " Z'";
        console.log(drawCommands);
    }

    Process {
        id: screenshot
        command: ["sh", "-c", `grim -l 0 -g '${screen.x},${screen.y} ${screen.width}x${screen.height}' /tmp/quickshot.png`]
        running: true
        stdout: StdioCollector { 
          onStreamFinished: console.log(this.text)
        }
        stderr: StdioCollector {
          onStreamFinished: console.log(this.text)
        }
        onExited: {
            console.log("done screenshotting");
        }
    }

    property var pathPoints: []
    property var oldX
    property var oldY

    Item {
        anchors.fill: parent

        Shape {
            anchors.fill: parent

            ShapePath {
                id: shapePath

                strokeWidth: 3
                strokeColor: "blue"
                fillColor: "lightblue"

                startX: 0
                startY: 0
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPressed: {
                pathPoints = [];
                shapePath.pathElements = [];

                pathPoints.push(Qt.point(mouse.x, mouse.y));
                shapePath.pathElements = [display.createPathMove(mouse.x, mouse.y)];

                oldX = mouse.x;
                oldY = mouse.y;
            }

            onPositionChanged: {
                if (pressed && (mouse.x - oldX) ** 2 + (mouse.y - oldY) ** 2 > 8000) {
                    oldX = mouse.x;
                    oldY = mouse.y;
                    pathPoints.push(Qt.point(mouse.x, mouse.y));

                    var newElements = [display.createPathMove(pathPoints[0].x, pathPoints[0].y)];

                    for (var i = 1; i < pathPoints.length; i++) {
                        newElements.push(display.createPathLine(pathPoints[i].x, pathPoints[i].y));
                    }

                    shapePath.pathElements = newElements;
                }
            }

            onReleased: {
                shapePath.pathElements.push(display.createPathLine(pathPoints[0].x, pathPoints[0].y));
                cropImage();
            }
        }
    }
}

