import Quickshell
import Quickshell.Widgets
import Quickshell.DBusMenu
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import QtQuick.Effects
import qs.theme
import qs.components

//yoinked this code from whisker by corecathx with a couple small modifications. shoutout, ts is great :pray:


Item {
  id: root
  readonly property Repeater items: items
  clip: false
  visible: width > 0 && height > 0
  implicitWidth: layout.width + 16
  implicitHeight: layout.height + 8

  Rectangle {
    color: Style.colBg
    anchors.fill: parent
    anchors.bottom: parent.bottom
    anchors.top: parent.top
    transform: [
      Shear { xFactor: 0.5 },
      Translate { x: -14; y: -4 }
    ]
  }

  GridLayout {
    id: layout
    rows: 2
    columns: 4
    rowSpacing: 10
    columnSpacing: 10

    Repeater {
      id: items
      model: SystemTray.items

      delegate: Item {
        id: trayItemRoot
        required property SystemTrayItem modelData
        implicitWidth: 20
        implicitHeight: 20

        IconImage {
          source: {
            let icon = trayItemRoot.modelData.icon
            if (icon.includes("?path=")) {
              icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
            }
            return icon
          }
          asynchronous: true
          anchors.fill: parent
        }

        HoverHandler { id: hover }

        QsMenuOpener {
          id: menuOpener
          menu: trayItemRoot.modelData.menu
        }

        StyledPopout {
          id: popout
          hoverTarget: hover
          interactable: true
          hCenterOnItem: true
          requiresHover: false

          Component {
            Item {
              width: childColumn.implicitWidth
              height: childColumn.height

              ColumnLayout {
                id: childColumn
                spacing: 5

                Repeater {
                  model: menuOpener.children
                  delegate: TrayMenuItem {
                    parentColumn: childColumn
                    Layout.preferredWidth: childColumn.width > 0 ? childColumn.width : implicitWidth
                  }
                }
              }
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
          hoverEnabled: true

          onClicked: {
            if (mouse.button === Qt.LeftButton){
              modelData.activate()
            }
            else if (mouse.button === Qt.MiddleButton){
              modelData.secondaryActivate()
            }
            else if (mouse.button === Qt.RightButton && popout.isVisible)
              popout.hide()
            else
              popout.show()
          }
        }
      }
    }
  }

  component TrayMenuItem: Item {
    id: itemRoot
    required property QsMenuEntry modelData
    required property ColumnLayout parentColumn

    Layout.fillWidth: true
    implicitWidth: rowLayout.implicitWidth + 10
    implicitHeight: !itemRoot.modelData.isSeparator ? rowLayout.implicitHeight + 10 : 1

    MouseArea {
      id: hover
      hoverEnabled: itemRoot.modelData.enabled
      anchors.fill: parent
      onClicked: {
        if (!itemRoot.modelData.hasChildren)
          itemRoot.modelData.triggered()
      }
    }

    Rectangle {
      id: itemBg
      anchors.fill: parent
      opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
      color: itemRoot.modelData.isSeparator
        ? Style.colBg_alt
        : hover.containsMouse ? Style.colBlack : Style.colBg
      }

      RowLayout {
        id: rowLayout
        visible: !itemRoot.modelData.isSeparator
        opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
        spacing: 5
        anchors {
          left: itemBg.left
          leftMargin: 5
          top: itemBg.top
          topMargin: 5
        }

        IconImage {
          visible: itemRoot.modelData.icon !== ""
          source: itemRoot.modelData.icon
          width: 15
          height: 15
        }

        StyledText {
          text: itemRoot.modelData.text
          font.pointSize: 8
          color: Style.colFg
        }

        MaterialIcon {
          visible: itemRoot.modelData.hasChildren
          icon: "󰄾"
          font.pointSize: 8
          color: Style.colFg
        }
      }
  }
}

