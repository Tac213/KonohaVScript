import QtQuick
import QtQuick.Layouts
import "." as NodeGraphItems

Item {
    id: root
    width: contentLayout.width + this.wingWidth + this.contentOffset * 2
    height: 100
    property int nodeID: -1
    property string nodeClassName: ''
    property real wingWidth: 20
    property real contentOffset: 15

    Rectangle {
        id: wing
        width: root.wingWidth
        height: root.height
        color: 'LightCoral'
    }
    NodeGraphItems.StatementNodeShape {
        id: body
        x: root.wingWidth
        y: 0
        width: root.width - root.wingWidth
        height: root.height
        fillColor: 'LightSlateGray'
    }
    RowLayout {
        id: contentLayout
        x: root.wingWidth + root.contentOffset
        y: root.height / 2 - this.height / 2
        Text {
            text: 'Hello World'
            color: 'white'
            font.pixelSize: 24
        }
        NodeGraphItems.ExpressionNodeShape {
            id: parameter0
            x: 100
            y: 20
            width: 100
            height: root.height - 40
            fillColor: 'white'
            strokeColor: 'black'
        }
        Text {
            text: 'with'
            color: 'white'
            font.pixelSize: 24
        }
        NodeGraphItems.ExpressionNodeShape {
            id: parameter1
            x: 100
            y: 20
            width: 100
            height: root.height - 40
            fillColor: 'white'
            strokeColor: 'black'
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
    }
}
