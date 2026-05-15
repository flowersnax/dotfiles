import QtQuick
import qs.services
import qs.theme

//reactive clock component that displays the system time in styled container
Rectangle {
  id: root 

  //dimensions
  implicitWidth: Style.innerTopBarThickness
  implicitHeight: timeLabel.contentHeight + 32
  color: "transparent"

  Rectangle {
    color: Style.colBg
    radius: 2
    anchors.fill: parent
    transform: [
      Shear { yFactor: 0.5 },
      Translate { y: -8 }
    ]
  }

  //renders the current time string provided by the global Time service
  Text {
    id: timeLabel

    anchors.centerIn: parent

    //direct binding to Time service telemetry
    text: Time.clockonly
    color: Style.colMuted

    font {
      family: Style.fontFamily
      pointSize: 8
    }
  }
}
