import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import qs.theme
import qs.services
import qs.components

//copied most of this from PartyWumpus's dotfiles on github, so shoutout to them :)


WrapperItem {
  id: root  
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  anchors.centerIn: parent
  height: 25
  
  function lengthStr(length: int): string {
    if (length <= 0) {
      return `-:--`;
    }
    const min = Math.floor(length / 60);
    const sec = Math.floor(length % 60);
    const sec0 = sec < 10 ? "0" : "";
    return `${min}:${sec0}${sec}`;
  }

  RowLayout {
    id: layout
    spacing: 7

    Repeater {
      model: Mpris.players

      Item {
        id: media

        Layout.alignment: Qt.AlignTop
        required property int index
        readonly property MprisPlayer player: Mpris.players.values[index]
        
        implicitWidth: rect.width
        visible: {
          !(player.title === undefined && player.artist === undefined && player.position === 0);
        }

        Timer {
          //only emit the signal when the position is actually changing
          running: media.player.playbackState == MprisPlaybackState.Playing
          //make sure the position updates at least once per second
          interval: 1000
          repeat: true
          //emit the positionChanged signal every second
          onTriggered: media.player.positionChanged()
        }

        ClippingRectangle {
          id: rect
          implicitWidth: 400
          implicitHeight: 18
          color: Style.colBlack

          Behavior on implicitHeight {
            SequentialAnimation {
              NumberAnimation {
                duration: 150
                easing.type: Easing.OutCirc
              }
            }
          }

          MouseArea {
            id: expandArea
            states: [
              State {
                name: "expanded"
                when: expandArea.containsMouse

                PropertyChanges {
                  rect.implicitHeight: 50
                }
              },
              State {
                name: "unexpanded"
                when: !expandArea.containsMouse

                PropertyChanges {
                  rect.implicitHeight: 18
                }
              }
            ]
            anchors.fill: parent
            hoverEnabled: true
            
            WrapperItem {
              anchors.bottom: parent.bottom
              anchors.left: parent.left
              anchors.right: parent.right
              bottomMargin: 20
              leftMargin: 5
              rightMargin: 5
              //width: 300

              RowLayout {
                Layout.fillWidth: true

                MouseArea {
                  id: albumIconArea
                  Layout.alignment: Qt.AlignCenter
                  implicitHeight: 30
                  implicitWidth: 30
                  hoverEnabled: true
                  Image {
                    id: albumIcon
                    Layout.alignment: Qt.AlignCenter
                    retainWhileLoading: true

                    source: media.player.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.Stretch
                    sourceSize.width: 30
                    sourceSize.height: 30
                  }

                  StyledToolTip {
                    text: player.trackAlbum || "[Unknown Album]"
                    visible: albumIconArea.containsMouse
                    topInset: 30
                    topPadding: 30
                  }
                }
                  MediaButton {
                    Layout.alignment: Qt.AlignCenter
                    icon: "󰒮"
                    enabled: media.player.canGoPrevious
                    implicitWidth: 15
                    implicitHeight: 15
                    onClicked: () => {
                      media.player.previous();
                  }
                }
                MediaButton {
                  Layout.alignment: Qt.AlignCenter
                  implicitWidth: 15
                  implicitHeight: 15
                  icon: media.player.isPlaying ? "" : "󰐊"
                  enabled: media.player.canTogglePlaying
                  onClicked: () => {
                    media.player.togglePlaying();
                  }
                }
                MediaButton {
                  Layout.alignment: Qt.AlignCenter
                  icon: "󰒭"
                  enabled: media.player.canGoNext
                  implicitWidth: 15
                  implicitHeight: 15
                  onClicked: () => {
                    media.player.next();
                  }
                }
                MouseArea {
                  id: mediaPlayerIconArea
                  Layout.alignment: Qt.AlignCenter
                  implicitHeight: 30
                  implicitWidth: 30
                  hoverEnabled: true
                  onClicked: () => {
                    Hyprland.dispatch(`togglespecialworkspace music`);
                  }
                  IconImage {
                    id: mediaPlayerIcon
                    anchors.fill: parent
                    implicitSize: 30
                    source: Quickshell.iconPath(DesktopEntries.heuristicLookup(media.player.identity)?.icon ?? "", "../../icons/musicnote.png")
                    asynchronous: true
                  }
                }
              }
            }

            WrapperItem {
              id: songLength
              anchors.bottom: parent.bottom
              anchors.right: parent.right
              rightMargin: 1
              StyledText {
                font.pointSize: 8
                font.bold: true
                color: Style.colMuted
                text: {
                  `// ${root.lengthStr(media.player.position)}/${root.lengthStr(media.player.length)}`;
                }
              }
            }

            ClippingRectangle {
              id: infoWrapper 
              implicitWidth: 300
              implicitHeight: parent.height
              color: "transparent"
              WrapperItem {
                anchors.bottom: parent.bottom
                leftMargin: 8
                StyledText {
                  id: songInfo
                  text: MprisInfo.artist + " ~ " + MprisInfo.title

                  SequentialAnimation {
                    running: infoWrapper.width - songInfo.width < 0
                    loops: Animation.Infinite
                    NumberAnimation {
                      target: songInfo
                      property: "x"
                      to: (infoWrapper.width - songInfo.width) - 2
                      duration: 2000
                    }
                    PauseAnimation {
                      duration: 5000
                    }
                    NumberAnimation {
                      target: songInfo
                      property: "x"
                      to: 2
                      duration: 2000
                    }
                    PauseAnimation {
                      duration: 5000
                    }
                  }

                  SequentialAnimation {
                    running: infoWrapper.width - songInfo.width >= 0
                    NumberAnimation {
                      target: songInfo
                      property: "x"
                      to: (infoWrapper.width - songInfo.width) / 2
                      duration: 1
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
