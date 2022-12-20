import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property real pinOffset: 10
    property real pinWidth: 16
    property real pinHeight: 32
    property alias fillColor: bodyPath.fillColor
    property alias strokeColor: bodyPath.strokeColor
    ShapePath {
        id: bodyPath
        fillColor: 'LightSalmon'
        startX: root.pinWidth
        startY: 0
        PathLine {
            x: bodyPath.startX
            y: bodyPath.startY + root.pinOffset
        }
        PathLine {
            x: bodyPath.startX - root.pinWidth
            y: bodyPath.startY + root.pinOffset + root.pinHeight / 2
        }
        PathLine {
            x: bodyPath.startX
            y: bodyPath.startY + root.pinOffset + root.pinHeight
        }
        PathLine {
            x: bodyPath.startX
            y: root.height
        }
        PathLine {
            x: root.width
            y: root.height
        }
        PathLine {
            x: root.width
            y: bodyPath.startY
        }
        PathLine {
            x: bodyPath.startX
            y: bodyPath.startY
        }
    }
}
