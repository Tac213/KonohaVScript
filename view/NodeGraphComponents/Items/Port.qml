import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    width: 16
    height: 8

    ShapePath {
        id: path
        // fillColor: "red"
        PathLine {
            x: path.startX + root.width / 2
            y: path.startY + root.height
        }
        PathLine {
            x: path.startX + root.width
            y: path.startY
        }
        PathLine {
            x: path.startX
            y: path.startY
        }
    }
}
