pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  property color colBg: "#211f21"
  property color colBg_alt: "#37343a"
  property color colFg: "#e3e1e4"
  property color colMuted: "#605d68"
  property color colBlack: "#1a181a"
  property color colRed: "#f85e84"
  property color colRed_alt: "#55393d"
  property color colOrange: "#ef9062"
  property color colYellow: "#e5c463"
  property color colYellow_alt: "#4e432f"
  property color colGreen: "#9ecd6f"
  property color colGreen_alt: "#394634"
  property color colBlue: "#7accd7"
  property color colBlue_alt: "#354157"
  property color colPurple: "#ab9df2"
  property color colPurple_alt: "#433d51"

  //font
  property string fontFamily: "Monocraft"
  property int fontSize: 10

  //margins 
  property int barThickness: 64
  property int edgeThickness: 16
  property int innerTopBarThickness: 50
  property int padding: 4
  property int modulePadding: 12

  property int cornerRadius: 4

  readonly property int animDurationShort: 150
  readonly property int animDurationLong: 200
  readonly property int dotHeight: 20
  readonly property int spacingAmount: 10

}
