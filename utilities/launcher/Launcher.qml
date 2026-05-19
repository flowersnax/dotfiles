import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.theme
import qs.components

PanelWindow {
  id: launcherWindow

  implicitWidth: 760
  implicitHeight: 680
  color: "transparent"
  visible: false

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "launcher_overlay"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  exclusiveZone: -1

  anchors {
    bottom: true
  }

  margins {
    bottom: 0
  }

  function scoreMatch(name, query) {
    var nameLower = name.toLowerCase();
    var queryLower = query.toLowerCase();

    //exact match
    if (nameLower === queryLower)
      return 1000;

    //full name starts with query
    if (nameLower.startsWith(queryLower))
      return 800;

    //any word in the name starts with query
    var words = nameLower.split(/[\s\-_]+/); //god i fucking hate regexes. thank god other people hate themselves enough to learn how they work /j
    for (var i = 0; i < words.length; i++) {
      if (words[i].startsWith(queryLower))
        return 600;
      }

    //single/double letter matches polluting short queries
    if (query.length >= 3 && nameLower.indexOf(queryLower) !== -1)
      return 200;

    return -1;
  }

  function buildFilteredList() {
    var allApps = DesktopEntries.applications.values;
    var query = ctrl.searchText.trim();

    if (query === "") {
      return allApps.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    var scored = [];
    for (var i = 0; i < allApps.length; i++) {
      var entry = allApps[i];

      var best = scoreMatch(entry.name, query);

      if(best < 0) {
        if (entry.genericName) {
          var gs = scoreMatch(entry.genericName, query);
          if (gs >= 600) //only word-prefix or better from secondary fields
            best = Math.max(best, gs - 100);
        }
      }

      if (best >= 0)
        scored.push({
          entry: entry,
          score: best
        });
      }

      scored.sort((a, b) => {
        if (b.score !== a.score)
          return b.score - a.score;
        return a.entry.name.localeCompare(b.entry.name);
      });

      return scored.map(s => s.entry);
    }

    LauncherBackend {
      id: ctrl

      onOpenMenuRequested: {
        if (launcherWindow.visible) {
          closeMenu();
        } else {
          searchField.text = "";
          ctrl.searchText = "";
          launcherWindow.visible = true;
          focusGrab.active = true;

          searchField.forceActiveFocus();
          listView.currentIndex = 0;
        }
      }

      onCloseMenuRequested: closeMenu()
    }

    HyprlandFocusGrab {
      id: focusGrab
      windows: [launcherWindow]
      onCleared: closeMenu()
    }

    function closeMenu() {
      launcherWindow.visible = false;
      focusGrab.active = false;
    }

    Item {
      anchors.fill: parent
      anchors.margins: 40
      anchors.bottomMargin: 10

      Rectangle {
        id: shadowCaster
        anchors.fill: mainUi
        radius: 28
        color: "black"
        visible: false
      }

      MultiEffect {
        anchors.fill: shadowCaster
        source: shadowCaster
        shadowEnabled: true
        shadowBlur: 2.5
        shadowColor: "#70000000"
        shadowVerticalOffset: 16
      }

      Rectangle {
        id: mainUiMask
        anchors.fill: mainUi
        radius: 28
        color: "black"
        visible: false
        layer.enabled: true
      }

      Rectangle {
        id: mainUi
        anchors.fill: parent
        color: Style.colBg
        radius: 28
        focus: true

        layer.enabled: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: mainUiMask
        }

        Keys.onPressed: event => {
          if (searchField.activeFocus)
            return;

          if (event.key === Qt.Key_Escape) {
            closeMenu();
            event.accepted = true;
          } else if (event.key === Qt.Key_slash || event.key === Qt.Key_I) {
            searchField.forceActiveFocus();
            event.accepted = true;
          } else if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
            listView.incrementCurrentIndex();
            event.accepted = true;
          } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
            listView.decrementCurrentIndex();
            event.accepted = true;
          } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (listView.currentItem)
              listView.currentItem.launch();
            event.accepted = true;
          }
        }

        Item {
          id: searchArea
          width: parent.width
          height: 84
          anchors.top: parent.top

          TextField {
            id: searchField
            anchors.fill: parent
            leftPadding: 68
            rightPadding: 32

            font {
              family: Style.fontFamily
              pointSize: Style.fontSize
              weight: Font.Medium
            }
            color: Style.colBg_alt
            selectionColor: Style.colBlue_alt
            selectedTextColor: Style.colBlue

            placeholderText: ">// awaiting input..._"
            placeholderTextColor: Style.colMuted

            background: Item {
              Text {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                text: "search"
                font {
                  family: Style.fontFamily
                  pointSize: Style.fontSize
                }
                color: searchField.activeFocus ? Style.colFg : Style.colBlue
                Behavior on color {
                  ColorAnimation {
                    duration: 150
                  }
                }
              }
            }

            onTextChanged: {
              ctrl.searchText = text;
              listView.currentIndex = 0;
            }

            Keys.onPressed: event => {
              if (event.key === Qt.Key_escape) {
                mainUi.forceActiveFocus();
                event.accepted = true;
              } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (listView.currentItem)
                  listView.currentItem.launch();
                event.accepted = true;
              } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier))) {
                  listView.incrementCurrentIndex();
                  event.accepted = true;
              } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier))) {
                  listView.decrementCurrentIndex();
                  event.accepted = true;
              }
            }
          }

          Rectangle {
            anchors {
              bottom: parent.bottom
              left: parent.left
              right: parent.right
              leftMargin: 24
              rightMargin: 24
            }
            height: 1
            color: Style.colMuted
            opacity: 0.4
          }
        }

        Item {
          id: listContainer
          anchors {
            top: searchArea.bottom
            bottom: footer.top
            left: parent.left
            right: parent.right
          }
          clip: true

          ListView {
            id: listView
            anchors.fill: parent
            topMargin: 12
            bottomMargin: 24
            spacing: 4

            highlightMoveDuration: 120
            highlightFollowsCurrentItem: true
            delegate: LauncherDelegate {}

            model: ScriptModel {
              values: launcherWindow.buildFilteredList()
            }
          }

          Rectangle {
            anchors {
              bottom: parent.bottom
              left: parent.left
              right: parent.right
            }

            height: 48
            gradient: Gradient {
              GradientStop {
                position: 0.0
                color: "transparent"
              }
              GradientStop {
                position: 1.0
                color: Style.colBg
              }
            }
          }
        }

        StyledText {
          id: emptyMessage
          anchors.centerIn: listContainer
          text: "no matching applications"
          visible: listView.count === 0
        }
      }

      Item {
        id: footer
        anchors {
          bottom: parent.bottom
          left: parent.left
          right: parent.right
        }
        height: 48

        StyledText {
          anchors.centerIn: parent
          text: "[/] search // [Enter] launch // [J/K] navigate // [Esc] close"
          opacity: 0.7
          font.letterSpacing: 0.5
        }
      }
    }
}
