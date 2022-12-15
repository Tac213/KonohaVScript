import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property real startX: 0
    property real startY: 0
    property real endX: 0
    property real endY: 0

    ShapePath {
        strokeWidth: 4
        strokeColor: 'red'
        fillColor: 'transparent'
        startX: root.startX
        startY: root.startY
        PathCubic {
            x: root.endX
            y: root.endY
            control1X: root.startX + (root.endX - root.startX) / 2
            control1Y: root.startY
            control2X: root.startX + (root.endX - root.startX) / 2
            control2Y: root.endY
        }
    }
}
