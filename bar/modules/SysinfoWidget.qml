import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
  id: root

  property string kernelVersion: "Linux"
  property int cpuUsage: 0
  property int memUsage: 0
  property int diskUsage: 0
  property int volumeLevel: 0


  //cpu tracking
  property var lastCpuIdle: 0
  property var lastCpuTotal: 0


  PanelWindow {

    anchors {
      top: true
    }

    implicitWidth: 480
    implicitHeight: 240
    exclusiveZone: 0
    focusable: true

    color: "transparent"

    //kernel version
    Process {
      id: kernelProc
      command: ["uname", "-r"]
      stdout: SplitParser {
        onRead: data => {
          if (data) kernelVersion = data.trim()
        }
      }
      Component.onCompleted: running = true
    }

    //cpu usage
    Process {
      id: cpuProc
      command: ["sh", "-c", "head -1 /proc/stat"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var parts = data.trim().split(/\s+/)
          var user = parseInt(parts[1]) || 0
          var nice = parseInt(parts[2]) || 0
          var system = parseInt(parts[3]) || 0
          var idle = parseInt(parts[4]) || 0
          var iowait = parseInt(parts[5]) || 0
          var irq = parseInt(parts[6]) || 0
          var softirq = parseInt(parts[7]) || 0

          var total = user + nice + system + idle + iowait + irq + softirq
          var idleTime = idle + iowait

          if (lastCpuTotal > 0) {
            var totalDiff = total - lastCpuTotal
            var idleDiff = idleTime - lastCpuIdle
            if (totalDiff > 0){
              cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
            }
          }
          lastCpuTotal = total
          lastCpuIdle = idleTime
        }
      }
      Component.onCompleted: running = true
    }

    //memory usage
    Process {
      id: memProc
      command: ["sh", "-c", "free | grep Mem"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var parts = data.trim().split(/\s+/)
          var total = parseInt(parts[1]) || 1
          var used = parseInt(parts[2]) || 0
          memUsage = Math.round(100 * used / total)
        }
      }
      Component.onCompleted: running = true
    }

    //disk usage
    Process {
      id: diskProc
      command: ["sh", "-c", "df / | tail -1"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var parts = data.trim().split(/\s+/)
          var percentStr = parts[4] || "0%"
          diskUsage = parseInt(percentStr.replace('%', '')) || 0
        }
      }
      Component.onCompleted: running = true
    }

    //volume level (wpctl for pipewire)
    Process {
      id: volProc
      command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var match = data.match(/Volume:\s*([\d.]+)/)
          if (match) {
            volumeLevel = Math.round(parseFloat(match[1]) * 100)
          }
        }
      }
      Component.onCompleted: running = true
    }

    //slow timer for system stats
    Timer {
      interval: 2000
      running: true
      repeat: true
      onTriggered: {
        cpuProc.running = true
        memProc.running = true
        diskProc.running = true
        volProc.running = true
      }
    }

    Rectangle {

      anchors.fill: parent

      radius: 6
      color: Style.colBg
      

      ColumnLayout {

      Text {
        text: kernelVersion
        color: Style.colRed
        font.pixelSize: Style.fontSize
        font.family: Style.fontFamily
        font.bold: true
        Layout.bottomMargin: 8
        Layout.leftMargin: Style.leftPadding
      }

      Text {
        text: " " + cpuUsage + "%"
        color: Style.colYellow
        font.pixelSize: Style.fontSize
        font.family: Style.fontFamily
        font.bold: true
        Layout.bottomMargin: 8
        Layout.leftMargin: Style.leftPadding
      }

      Text {
        text: " " + memUsage + "%"
        color: Style.colCyan
        font.pixelSize: Style.fontSize
        font.family: Style.fontFamily
        font.bold: true
        Layout.bottomMargin: 8
        Layout.leftMargin: Style.leftPadding
      }

      Text {
        text: " " + diskUsage + "%"
        color: Style.colBlue
        font.pixelSize: Style.fontSize
        font.family: Style.fontFamily
        font.bold: true
        Layout.bottomMargin: 8
        Layout.leftMargin: Style.leftPadding
      }

      Text {
        text: " " + volumeLevel + "%"
        color: Style.colPurple
        font.pixelSize: Style.fontSize
        font.family: Style.fontFamily
        font.bold: true
        Layout.bottomMargin: 8
        Layout.leftMargin: Style.leftPadding
      }

    }
    }
  }
}
