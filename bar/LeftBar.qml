import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules"
import qs.theme
import qs.services

//primary status bar rendered on all monitors

Variants {
  id: root
  model: Quickshell.screens

  delegate: PanelWindow {
    id: mainBar

    //screen mapping
    required property var modelData
    screen: modelData

    //layer shell config
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-leftbar"

    //positioning
    anchors {
      top: true
      left: true
      bottom: true
    }

    //visual styling
    color: "transparent"
    implicitWidth: Style.barThickness

    // -- core modules -- 

    // workspace switcher 
    Workspaces {
      id: workspaceModule
      targetMonitor: modelData.name

      anchors {
        top: parent.top
        topMargin: 16
        horizontalCenter: parent.horizontalCenter
      }
    }

    //TODO: put a focused window thingy in here somewhere
    //ideally wanna have that window preview thing that caelestia's got going on
    //but that's way out of my depth at the moment lmao

    

    //calendar
    Calendar {
      id: calendarModule
      anchors{
        bottom: statusModule.top
        bottomMargin: Style.modulePadding
        horizontalCenter: parent.horizontalCenter
      }

    }

    //battery & volume
    SystemStats {
      id: statusModule

      anchors{
        bottom: parent.bottom
        bottomMargin: 16
        horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
