import QtQuick
import QtQuick.Controls.Basic
import qs.theme

ToolTip {
  id: control

    contentItem: Text {
        text: control.text
        font: Style.fontFamily
        color: Style.colFg
    }

    background: Rectangle {
        border.color: Style.colBg_alt
        color: Style.colBg
        radius: 2
    }
}
