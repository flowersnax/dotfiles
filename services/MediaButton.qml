import Quickshell
import QtQuick

MouseArea {
  id: root
  property bool enabled: true
  required property string icon
  Text {
    color: root.enabled ? "white" : "grey"
    anchors.fill: parent
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignVCenter
    text: icon
    font.pointSize: 14
  }
}
