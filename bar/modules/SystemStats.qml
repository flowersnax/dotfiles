import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.theme

//unified system status indicator for audio and power
Rectangle {
  id: root

  //layout config
  implicitWidth: Style.innerTopBarThickness
  implicitHeight: contentLayout.height + 30
  color: "transparent"
  Rectangle {
    color: Style.colBg
    anchors.fill: parent
    radius: 2
    transform: [
      Shear { yFactor: 0.5 },
      Translate { y: -10 }
    ]
    }
  //audio state management
  readonly property var activeSink: Pipewire.defaultAudioSink
  readonly property bool isMuted: activeSink?.audio?.muted ?? true
  readonly property real volumeLevel: activeSink?.audio?.volume ?? 0.0

  //ensures pipewire sink stays reactive to external system changes
  PwObjectTracker {
    objects: root.activeSink ? [root.activeSink] : []
  }

  Column {
    id: contentLayout
    anchors.centerIn: parent
    spacing: 16

    //audio module
    Column {
      id: volumeModule
      spacing: 8

      Text {
        id: volumeIcon
        anchors.horizontalCenter: parent.horizontalCenter
        font {
          family: Style.fontFamily
          pointSize: Style.fontSize
        }
        color: root.isMuted ? Style.colRed_alt : Style.colMuted

        text: {
          if (!root.activeSink?.audio)
            return ""; // no device
          if (root.isMuted)
            return ""; //muted
          if (root.volumeLevel >= 0.6)
            return ""; //high
          if (root.volumeLevel >= 0.3)
            return ""; //mid
          return ""; //low
        }
      }

      Text {
        id: volumeLabel
        anchors.horizontalCenter: parent.horizontalCenter
        color: Style.colMuted
        font {
          family: Style.fontFamily
          pointSize: Style.fontSize
        }
        text: root.activeSink?.audio ? Math.round(root.volumeLevel * 100) + "%" : "--%"
      }

      TapHandler {
        onTapped: if (root.activeSink?.audio)
          root.activeSink.audio.muted = !root.isMuted
        cursorShape: Qt.PointingHandCursor
      }

      
    }

    //separator
    Rectangle {
      visible: batteryModule.isVisible
      width: 16
      height: 1
      color: Style.colMuted
      anchors.horizontalCenter: parent.horizontalCenter
    }

    //battery module
    Column {
      id: batteryModule
      spacing: 8

      //internal logic to keep UI bindings clean
      readonly property bool isVisible: UPower.displayDevice?.isPresent ?? false
      readonly property real capacity: (UPower.displayDevice?.percentage ?? 0) * 100
      readonly property bool isCharging: !UPower.onBattery

      visible: isVisible

      Text {
        id: batteryIcon
        anchors.horizontalCenter: parent.horizontalCenter
        font {
          family: Style.fontFamily
          pointSize: Style.fontSize
        }

        //color logic: alert user if charging (active state) or critically low
        color: (batteryModule.isCharging && batteryModule.capacity < 100) || batteryModule.capacity <= 20 ? Style.colRed : Style.colMuted

        text: {
          if (!batteryModule.isVisible)
            return "";
          if (batteryModule.isCharging && batteryModule.capacity < 100)
            return "";
          
          //capacity breakpoints
          if (batteryModule.capacity >= 90)
            return"󰂂";
          if (batteryModule.capacity >= 70)
            return "󰂀";
          if (batteryModule.capacity >= 50)
            return "󰁾";
          if (batteryModule.capacity >= 30)
            return "󰁼";
          if (batteryModule.capacity >= 10)
            return "󰁺";
          return "󰂃";
        }
      }

      Text {
        id: batteryLabel
        anchors.horizontalCenter: parent.horizontalCenter
        color: Style.colMuted
        font {
          family: Style.fontFamily
          pointSize: Style.fontSize
        }
        text: Math.round(batteryModule.capacity) + "%"
      }
    }
  }
}
