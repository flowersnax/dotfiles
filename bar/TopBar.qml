import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme
import "modules"

Variants {
  id: root
  model: Quickshell.screens

  delegate: PanelWindow {
    id: topBarWindow

    //screen mapping
    required property var modelData
    screen: modelData

    //layer shell config
    WlrLayershell.layer: WlrLayer.Top

    //geometry & positioning
    anchors {
      top: true
      left: true
      right: true
    }

    //visual styling
    implicitHeight: Style.barThickness / 1.5
    color: "transparent"

    SysTray {
      id: systemTray
      anchors {
        left: parent.left
        leftMargin: 132
        top: parent.top
        topMargin: 10
      }
    }

    Media { //not sure when or how, but the weird bug i was having with the 
            //song progress indicator resolved itself on its own?
      id: nowPlaying
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
      }
    }
  }
}
