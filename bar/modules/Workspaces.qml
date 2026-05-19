import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.theme


Rectangle {
  id: root
  implicitWidth: Style.innerTopBarThickness
  implicitHeight: mainLayout.height + 24
  color: "transparent"

  //config
  property string targetMonitor: ""

  Rectangle {
    radius: 2
    color: Style.colBg
    anchors.fill: parent
    transform: [
      Shear { yFactor: 0.5 },
      Translate { y: -8 }
    ]
  }


  Column {
    id: mainLayout
    anchors.centerIn: parent
    spacing: Style.spacingAmount
    Repeater { 
          model: Hyprland.workspaces

          delegate: Rectangle {
            id: workspaceDot
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            //only show workspaces belonging to the assigned monitor
            visible: modelData.id >= 1 && modelData.monitor?.name === root.targetMonitor

            Text {
              height: Style.dotHeight
              font.bold: (modelData.active || modelData.focused) ? true : false
              font.family: Style.fontFamily
              font.pixelSize: {
                  if (!visible)
                    return 0;
                  if (modelData.focused || modelData.active || dotMouseArea.hovered)
                    return 22;
                  return 20;
              }

              color: {
                if (modelData.focused)
                  return Style.colMuted;
                return dotMouseArea.hovered ? Style.colGreen : Style.colBg_alt;
              }

              text: {
                if (modelData.focused || modelData.active || dotMouseArea.hovered || (modelData.toplevels.values?.length != 0 || null))
                  return "★";
                return "☆";
              }
            }

            height: Style.dotHeight
            width: Style.dotHeight

            Behavior on width {
              NumberAnimation {
                duration: Style.animDurationLong
                easing.type: Easing.OutBack
              }
            }

            Behavior on color {
              ColorAnimation {
                duration: Style.animDurationShort
              }
            }

            TapHandler {
              onTapped: modelData.activate()
            }

            HoverHandler {
              id: dotMouseArea
              cursorShape: Qt.PointingHandCursor
            }
          }
    }
  }
}
