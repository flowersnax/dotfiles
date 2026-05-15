import Quickshell
import QtQuick
import qs.theme

PopupWindow {
    id: tooltipPopup

    // Required properties
    required property var targetWidget
    required property bool triggerTarget
    required property rect position
    required property int expandDirection

    // Optional properties
    property int showDelay: 800
    property int hideDelay: 200
    property color backgroundColor: Style.colBlack // add default color from theme
    property real backgroundRadius: 4 // add default rounding from theme
    property bool blockShow: false // NEW: override showing (ex. when a menu is open)

    // do not mess with these unless required
    default property alias data: contentContainer.data
    property bool shouldShow: (targetWidget?.hovered ?? false) || isHovered
    property bool isHovered: mouseArea.containsMouse

    function forceHide() {
        showTimer.stop();
        internal.actuallyVisible = false;
    }

    anchor {
        item: targetWidget
        rect: position
        gravity: expandDirection
    }

    color: "transparent"
    visible: internal.actuallyVisible
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    QtObject {
        id: internal
        property bool actuallyVisible: false
    }

    // Delay timers for smooth hover behavior
    Timer {
        id: showTimer
        interval: tooltipPopup.showDelay
        onTriggered: internal.actuallyVisible = true
    }

    Timer {
        id: hideTimer
        interval: tooltipPopup.hideDelay
        onTriggered: internal.actuallyVisible = false
    }

    // Watch for shouldShow changes
    onShouldShowChanged: {
        if (shouldShow && !blockShow) {
            hideTimer.stop();
            showTimer.start();
        } else {
            showTimer.stop();
            hideTimer.start();
        }
    }

    Rectangle {
        id: content
        color: tooltipPopup.backgroundColor
        radius: tooltipPopup.backgroundRadius
        implicitWidth: contentContainer.implicitWidth + (Style.padding * 2)
        implicitHeight: contentContainer.implicitHeight + (Style.padding * 2)
        
        // animation magic
        scale: internal.actuallyVisible ? 1.0 : 0.8
        opacity: internal.actuallyVisible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: 150// animation duration
                easing.type: Easing.OutBack
                //easing.bezierCurve: // animation easing curve (list<real>)
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150// animation duration
                easing.type: Easing.OutBack
               //easing.bezierCurve: // animation easing curve (list<real>)
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton

            // Forward clicks to target widget action if it exists & is enabled
            onClicked: {
                if (tooltipPopup.targetWidget?.action && tooltipPopup.triggerTarget) {
                    tooltipPopup.targetWidget.action.trigger();
                }
            }
        }

        // Content container - this is where parent components inject their content
        Item {
            id: contentContainer
            anchors.centerIn: parent
            // Size will be determined by child content
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
