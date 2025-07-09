import QtQuick
import QtQuick.Layouts
import "root:/config"
import "root:/io"
import "root:/"

Rectangle {
    id: root
    height: Config.bar.sectionHeight
    radius: 10
    color: Colors.background
    border.width: Config.bar.borderWidth
    border.color: Colors.outline

    Layout.preferredWidth: notifIcon.width + Config.bar.componentPadding

    property bool active: false

// 
// 
// 
// 
    TextObjectIcons {
        id: notifIcon
        anchors.centerIn: parent
        text: active?"":""
        color: Colors.accent2
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              // root.active = !root.active
              // External.shutdown()
              console.log(quickshot.item)
              quickshot.item.visible = true
            }
        }
    }

    Quickshot {
      id: quickshot
    }

}
