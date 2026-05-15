import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme

Variants {
  id: root
  model: Quickshell.screens

  delegate: PanelWindow {
    id: rightBarWindow

    //screen mapping
    required property var modelData
    screen: modelData

    //layer shell config
    WlrLayershell.layer: WlrLayer.Top

    //geometry & positioning
    anchors {
      top: true
      right: true
      bottom: true
    }

    //visual styling
    implicitWidth: Style.edgeThickness
    color: "transparent"
  }
}
