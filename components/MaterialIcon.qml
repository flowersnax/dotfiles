import QtQuick

//copied from whisker

StyledText {
  id: root
  property real fill: 0
  property int grad: 0
  required property string icon

  font.hintingPreference: Font.PreferFullHinting
  antialiasing: true
  font.variableAxes: {
    "FILL": root.fill,
    "opsz": root.fontInfo.pixelSize,
    "GRAD": root.grad,
    "wght": root.fontInfo.weight
  }
  renderType: Text.QtRendering

  text: root.icon
}
