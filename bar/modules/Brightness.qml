import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.theme

ColumnLayout {
  id: root

  property bool shouldShowOSD: false
  property real brightness: 0
  property real maxBrightness: 100

  Layout.alignment: Qt.AlignHCenter
  spacing: 8

  Component.onCompleted: {
    getMaxBrightnessProcess.running = true
  }

  //public API (... whatever that means. stealing this code from some guy on reddit)
  function setBrightness(newBrightness) {
    const clamped = Math.max(0, Math.min(1, newBrightness))
    const value = Math.round(clamped * maxBrightness)

    brightness = clamped

    //trigger OSD
    shouldShowOSD = true
    hideOSDTimer.restart()

    try {
      setBrightnessProcess.command = ["brightnessctl", "set", `${value}`]
      setBrightnessProcess.running = true
      return true
    } catch (error) {
      console.error("[BrightnessService] Failed to set brightness:", error)
      return false
    }
  }

  function adjustBrightness() {
    return setBrightness(brightness + delta)
  }

  function cycleBrightness() {
    if (brightness <= 0.3)
      return setBrightness(0.6)

    if (brightness <= 0.6)
      return setBrightness(1)

    return setBrightness(0.3)
  }

  IpcHandler {
    target: "brightness"

    function increase(): void {
      root.adjustBrightness(0.1)
    }

    function decrease(): void {
      root.adjustBrightness(-0.1)
    }
  }

  //hide OSD timer
  Timer {
    id:hideOSDTimer
    interval: 1000
    onTriggered: root.shouldShowOSD = false
  }

  //get max brightness
  Process {
    id: getMaxBrightnessProcess
    command: ["brightnessctl", "max"]

    stdout: StdioCollector {
      onStreamFinished: {
        const value = parseInt(this.text)
        if(!isNaN(value)) {
          root.maxBrightness = value
          getBrightnessProcess.running = true
        }
      }
    }
  }

  //initial brightness fetch
  Process {
    id: getBrightnessProcess
    command: ["brightnessctl", "get"]

    stdout: StdioCollector {
      onStreamFinished: {
        const value = parseInt(this.text)
        if (!isNaN(value))
        root.brightness = value / root.maxBrightness
        console.log(value)
      }
    }
  }

  //set brightness
  Process {
    id: setBrightnessProcess
  }

  Rectangle {
    id: brightnessTextRect

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: root.shouldShowOSD ? brightnessText.implicitHeight : 0
    Layout.preferredWidth: brightnessText.implicitWidth
    color: "transparent"
    clip: true

    Text {
      id: brightnessText

      property int brightnessPercent: Math.round(root.brightness * 100)

      font.family: Style.fontFamily
      font.pixelSize: brightnessPercent > 99 ? 11 : 15
      text: brightnessPercent
      color: brightnessPercent < 30 ? Style.colBg_alt
           : brightnessPercent < 60 ? Style.colMuted
           : Style.colFg

      transform: Translate { x: 1 }

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Behavior on brightnessPercent {
        NumberAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }

      Behavior on font.pixelSize {
        NumberAnimation {
          duration: 100
          easing.type: Easing.Linear
        }
      }
    }

    Behavior on Layout.preferredHeight {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }
  }

  Text {
    id: brightnessIcon

    property int brightnessPercent: Math.round(root.brightness * 100)

    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: root.shouldShowOSD ? -2 : 10

    font.family: Style.fontFamily
    font.pixelSize: 18
    text: "󰃠"

    color: brightnessPercent < 30 ? Style.colBg_alt
         : brightnessPercent < 60 ? Style.colMuted
         : Style.colYellow

    transform : [
      Translate {
        id: brightnessIconTranslate
        x: 1

        Behavior on y {
          NumberAnimation {
            duration: 100
            easing.type: Easing.Linear
          }
        }
      },
      Rotation {
        angle: 360 * root.brightness
        origin.x: brightnessIcon.width / 2 + 1
        origin.y: brightnessIcon.height / 2
      }
    ]

    Behavior on color {
      ColorAnimation { duration: 250 }
    }
  }

  Behavior on brightness {
    NumberAnimation {
      duration: 150
      easing.type: Easing.Linear
    }
  }
}
