import QtQuick
import QtQuick.Shapes
import "." as NodeGraphItems

Item {
    id: root
    width: 300
    height: 100
    property real wingWidth: 20
    property real pinOffset: 30
    property real pinWidth: 32
    property real pinHeight: 16

    Rectangle {
        id: wing
        width: root.wingWidth
        height: root.height
        color: 'LightCoral'
    }
    Shape {
        id: body
        ShapePath {
            id: bodyPath
            fillColor: 'LightSlateGray'
            startX: root.wingWidth
            startY: 0
            PathLine {
                x: bodyPath.startX + root.pinOffset
                y: bodyPath.startY
            }
            PathLine {
                x: bodyPath.startX + root.pinOffset + root.pinWidth / 2
                y: bodyPath.startY + root.pinHeight
            }
            PathLine {
                x: bodyPath.startX + root.pinOffset + root.pinWidth
                y: bodyPath.startY
            }
            PathLine {
                x: root.width
                y: bodyPath.startY
            }
            PathLine {
                x: root.width
                y: bodyPath.startY + root.height
            }
            PathLine {
                x: bodyPath.startX + root.pinOffset + root.pinWidth
                y: bodyPath.startY + root.height
            }
            PathLine {
                x: bodyPath.startX + root.pinOffset + root.pinWidth / 2
                y: bodyPath.startY + root.height + root.pinHeight
            }
            PathLine {
                x: bodyPath.startX + root.pinOffset
                y: bodyPath.startY + root.height
            }
            PathLine {
                x: bodyPath.startX
                y: bodyPath.startY + root.height
            }
            PathLine {
                x: bodyPath.startX
                y: bodyPath.startY
            }
        }
    }
    Text {
        text: 'Hello World'
        color: 'white'
        x: root.wingWidth + root.pinOffset
        y: root.height / 2 - this.height / 2
        font.pixelSize: 24
    }
}
