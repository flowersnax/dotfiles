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
        topMargin: Style.spacerMedium
        horizontalCenter: parent.horizontalCenter
      }
    }

    //TODO: put a focused window thingy in here somewhere
    //ideally wanna have that window preview thing that caelestia's got going on
    //but that's way out of my depth at the moment lmao

    //as an update, after a couple days of fighting for my goddamn life i managed
    //to get a preview that looks halfway decent
    WindowInfo {
      id: windowModule
      anchors.bottom: calendarModule.top
      anchors.bottomMargin: Style.spacerMedium
      anchors.right: parent.right
      anchors.rightMargin: Style.spacerSmall
    }

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
        bottomMargin: Style.paddingLarge
        horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
