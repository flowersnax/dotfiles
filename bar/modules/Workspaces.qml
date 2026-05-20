import QtQuick
import QtQuick.Layouts
import QtQml.Models
import Quickshell.Wayland
import qs.theme
import qs.services

//referenced whisker by corecathx for a lot of this

Item {
  id: root
  implicitWidth: Style.innerTopBarThickness
  implicitHeight: mainLayout.height + 24

  //config

  Rectangle {
    radius: 6
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
      model: Hyprland.fullWorkspaces

      delegate: Rectangle {
        id: workspaceDot
        width: 20
        height: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        Text {
          height: Style.dotHeight
          anchors.centerIn: parent
          font.bold: focused ? true : false
          font.family: Style.fontFamily
          font.pointSize: focused ? 22 : dotMouseArea.containsMouse ? 20 : 18
          color: focused ? Style.colMuted : dotMouseArea.containsMouse ? Style.colGreen : Style.colBg_alt
          text: (focused || dotMouseArea.containsMouse || Hyprland.toplevels > 0) ? "★" : "☆"

          Behavior on font.pointSize {
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
        }

        MouseArea {
          id: dotMouseArea
          hoverEnabled: true
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (Hyprland.activeWsId !== id) Hyprland.dispatch(`workspace ${id}`)
        }
      }
    }
  }

  WheelHandler {
    id: wheel
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    target: root
    property real accumulatedDelta: 0
    property real threshold: 100

    onWheel: (event) => {
      const total = Hyprland.fullWorkspaces.count
      const current = Hyprland.focusedWorkspace.id

      accumulatedDelta += event.angleDelta.y

      if (Math.abs(accumulatedDelta) >= threshold) {
        if (accumulatedDelta > 0) {
          if (current > 1)
            Hyprland.dispatch("workspace -1")
          } else {
            if (current < total)
              Hyprland.dispatch("workspace +1")
          }
          
          accumulatedDelta = 0
      }

      event.accepted = true 
    }
  }
  /*MouseArea { //unimplimented atm
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    hoverEnabled: true

    onClicked: {
      if (popout.isVisible)
        popout.hide()
      else
        popout.show()
    }
  }
  HoverHandler {
    id: hover
  }
  StyledPopout {
    id: popout
    hoverTarget: hover
    interactable: true
    hCenterOnItem: true
    requiresHover: true
    Component {
      WorkspacePreview {}
    }
  }*/
}
