import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import qs.components
import qs.services
import qs.theme

//stole a little code from caelestia but ended up writing a lot of this myself actually

Item {
  id: root

  property string windowTitle: {
    const title = Hypr.activeToplevel?.title;
    if(!title)
      return qsTr("Desktop");
      return title;
      console.log(Hypr.activeToplevel)
    }

  implicitWidth: 50
  implicitHeight: 300
  anchors.horizontalCenter: parent.horizontalCenter
  

  MouseArea {
    id: mouseArea
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    anchors.fill: parent
  }

  //this was a BITCH to get right and its still not entirely where i want it. jfc
  PanelWindow {
    exclusiveZone: -1
    anchors.left: true
    anchors.top: true
    margins.top: 500
    margins.left: 64
    implicitWidth: preview.visible ? popout.width + 10 : 0
    implicitHeight: (preview.implicitHeight >= 300) ? 320 : preview.implicitHeight
    color: Style.colBlack
      ClippingRectangle {
        id: popout
        color: "transparent"
        implicitHeight: 300
        implicitWidth: preview.visible ? preview.implicitWidth - Style.padding : 0
        //looks ugly if you do the anchors any way other than this, tbh.
        //this code looks like buns but it works and thats what matters lmao
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 0
        ScreencopyView {
          id: preview
          captureSource: Hypr.activeToplevel.wayland
          constraintSize: Qt.size(sourceSize.width, 400)
          live: visible ? true : false
          visible: mouseArea.containsMouse ? true : false
          anchors {
            margins: Style.paddingSmall
          }
        }
      }
  }

  StyledText {
    id: text

    anchors.bottom: parent.bottom
    //anchors.top: parent.top
    anchors.left: parent.left
    width: 300
    horizontalAlignment: Text.AlignHCenter

    
    //anchors.topMargin: 4
    text: root.windowTitle

    font.pointSize: Style.fontSize
    font.family: Style.fontFamily
    elide: Qt.ElideRight
    color: Style.colFg
    transformOrigin: Item.Center

    transform: [
      Rotation {
        angle: 270
      }
    ]

  }
}
