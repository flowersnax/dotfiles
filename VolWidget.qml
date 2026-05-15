import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
  id: root

  // bind the pipewire node so its volume will be tracked
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }

  Connections {
    target: Pipewire.defaultAudioSink?.audio

    function onVolumeChanged() {
      root.shouldShowOsd = true;
      hideTimer.restart();
    }
  }

  property bool shouldShowOsd: false

  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: root.shouldShowOsd = false
  }

  // the osd window will be created and destroyed based on shouldShowOsd.
  // PanelWindow.visible could be set instead of using a loader, but using
  // a loader will reduce the memory overhead when the window isnt open
  LazyLoader {
    active: root.shouldShowOsd

    PanelWindow {
      // since the panel's screen is unset, it will be picked by the compositor
      // when the window is created. most compositors pick the current active monitor

      anchors.bottom: true
      margins.bottom: screen.height / 5
      exclusiveZone: 0

      implicitWidth: 400
      implicitHeight: 50
      color: "transparent"

      // an empty click mask prevents the window from blocking mouse events
      mask: Region {}

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#80000000"

        RowLayout {
          anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 15
          }

          IconImage {
            implicitSize: 30
            source: Quickshell.iconPath("audio-volume-high-symbolic")
          }

          Rectangle {
            // stretches to fill all left-over space
            Layout.fillWidth: true

            implicitHeight: 10
            radius: 20
            color: "#50ffffff"

            Rectangle {
              anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
              }

              implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
              radius: parent.radius
            }
          }
        }
      }
    }
  }
}
