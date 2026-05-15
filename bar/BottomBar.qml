import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme

//transparent shell container positioned at the bottom of every connected screen
Variants {
  id: root
  model: Quickshell.screens

  delegate: PanelWindow {
    id: bottomBarWindow

    //screen mapping
    required property var modelData
    screen: modelData

    //layer shell config
    WlrLayershell.layer: WlrLayer.Top

    //geometry & positioning
    anchors {
      left: true
      right: true
      bottom: true
    }

    //visual styling
    implicitHeight: Style.edgeThickness
    color: "transparent"
  }
}
