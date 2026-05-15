pragma Singleton

import Quickshell
import QtQuick

//global time provider for shell components
Singleton {
  id: root

  //formatted strings, added a few different variants here for different purposes
  readonly property string time: Qt.formatDateTime(clock.date, "h:mm ap // ddd, MM d")
  readonly property string timesmall: Qt.formatDateTime(clock.date, "h:mm ap \n ddd, MM d")
  readonly property string clockonly: Qt.formatDateTime(clock.date, "h:mm ap")

  //reactive clock tracking seconds
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
