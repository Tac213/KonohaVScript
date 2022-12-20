import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property real pinOffset: 30
    property real pinWidth: 32
    property real pinHeight: 16
    property alias fillColor: bodyPath.fillColor
    property alias strokeColor: bodyPath.strokeColor
    ShapePath {
        id: bodyPath
        fillColor: 'LightSlateGray'
        startX: 0
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
