pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Particles
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "root:/config"

LazyLoader {
    id: screenshotLoader
    active: GlobalStates.screenshotActive

    PanelWindow {
        id: display
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:screenshot"
        exclusionMode: ExclusionMode.Ignore

        implicitWidth: screen.width
        implicitHeight: screen.height
        color: "transparent"

        // TODO: change to execDetatched
        Component.onCompleted: screenshot.running = true

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
            Quickshell.execDetached(["sh", "-c", `magick /tmp/quickshot.png \\( -size $(identify -format "%wx%h" /tmp/quickshot.png) xc:none -fill white -stroke none -draw "${drawCommands}" \\) -alpha off -compose copy_opacity -composite -trim +repage ~/Pictures/screenshots/$(date -u +%Y-%m-%d-%H-%M-%S_quickshot.png)`]);
        }

        // TODO: change to screenshotting after drawing annotations?
        Process {
            id: screenshot
            command: ["sh", "-c", `grim -l 0 -g '${screen.x},${screen.y} ${screen.width}x${screen.height}' -s 1 /tmp/quickshot.png`]
            running: false
            stdout: StdioCollector { onStreamFinished: console.log(this.text) }
            // stderr: StdioCollector { onStreamFinished: console.log(this.text) }
            // onExited: {
            //   console.log(`grim -l 0 -g '${screen.x},${screen.y} ${screen.width}x${screen.height}' /tmp/quickshot.png`)
            // }
        }

        property var pathPoints: []
        property var oldX
        property var oldY

        MouseArea {
            id: mouseArea
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
                if (pressed && (mouse.x - oldX) ** 2 + (mouse.y - oldY) ** 2 > 300) {
                    randomEmitter.burst(10, mouse.x, mouse.y);
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
                GlobalStates.screenshotActive = false;
            }
        }

        Shape {
            anchors.fill: parent

            ShapePath {
                id: shapePath

                strokeWidth: 3
                strokeColor: "#40653BE0"
                fillColor: "#10653BE0"

                startX: 0
                startY: 0
            }
        }
        ParticleSystem {
            id: root
            anchors.fill: parent

            running: true

            /*
              Stolen from rexi :)))
              https://github.com/Rexcrazy804/Zaphkiel/blob/master/users/dots/quickshell/kurukurubar/Widgets/KuruParticleSystem.qml
              ...why such a long url.....
            */

            // star particles
            ImageParticle {
                autoRotation: true
                color: "#653BE0"
                colorVariation: 0.3
                entryEffect: ImageParticle.None
                groups: ["star"]
                rotationVariation: 360
                source: "qrc:///particleresources/star.png"
                opacityTable: "assets/opacityTable.png"
                sizeTable: "assets/sizeTable.png"
            }
            Emitter {
                id: randomEmitter
                Rectangle {
                    anchors.fill: parent
                }
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 30
                emitRate: 0
                endSize: 0
                group: "star"
                lifeSpan: 50000
                lifeSpanVariation: 1000
                size: 20
                sizeVariation: 30

                velocity: AngleDirection {
                    angleVariation: 360
                    magnitude: 15
                    magnitudeVariation: 5
                }
            }
        }
    }
}
