pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs.theme

// makes rounded bezels across all connected monitors
// uses an XOR region mask and an inverted MultiEffect mask to 
// render a solid surface with a transparent 'cutout' for the workspace

Variants {
  id: root
  model: Quickshell.screens

  delegate: PanelWindow {
    id: bezelWindow

    //model integration
    required property var modelData
    screen: modelData

    //window config
    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Top //writing this out is a bit redundant, but it can be nice to have everything laid out like this :)
    WlrLayershell.namespace: "quickshell-bezels"
    WlrLayershell.exclusiveZone: -1 //passthrough; do not reserve space

    //fill the whole screen
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    //input & visual masking
    //XOR intersection ensures clicks pass through the center cutout
    mask: Region {
      item: effectContainer
      intersection: Intersection.Xor
    }

    Item {
      id: effectContainer
      anchors.fill: parent

      Item {
        id: bezelLayer
        anchors.fill: parent
        layer.enabled: true

        Rectangle {
          id: bezelBackground
          anchors.fill: parent
          color: Style.colBlack
          layer.enabled: true

          //subtracts the cutoutShape from the solid surface 
          layer.effect: MultiEffect {
            maskSource: cutoutShape
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
          }
        }

        Rectangle {
          id: cornerLeft
          color: Style.colBlack
          layer.enabled: true

          anchors.left: parent.left
          anchors.top: parent.top

          width: 50; height: 150
          transformOrigin: Item.Top
          transform: [
            Rotation { angle: 45 },
            Translate { y: 0; x: 100 }
          ]
        }

        Rectangle {
          id: cornerRight
          color: Style.colBlack
          layer.enabled: true

          anchors.right: parent.right
          anchors.bottom: parent.bottom

          width: 50; height: 150
          transformOrigin: Item.Top
          transform: [
            Rotation { angle: 45 },
            Translate { y: 50; x: 50 }
          ]
        }

        //cutout definition - defines the area where the desktop remains visible
        Item {
          id: cutoutShape
          anchors.fill: parent
          layer.enabled: true
          visible: false //source item only

          Rectangle {
            id: clippingRect
            anchors.fill: parent

            //margins
            anchors {
              leftMargin: Style.barThickness
              rightMargin: Style.edgeThickness
              topMargin: Style.barThickness / 1.5
              bottomMargin: Style.edgeThickness
            }

            radius: Style.cornerRadius
          }
        }
      }
    }
  }
}
