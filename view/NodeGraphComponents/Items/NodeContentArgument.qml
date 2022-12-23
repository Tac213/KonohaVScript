import QtQuick
import "."

ExpressionNodeShape {
    id: root
    required property int index
    required property string argName
    width: 100
    height: 60
    fillColor: dropArea.containsDrag ? 'Aquamarine' : 'white'
    strokeColor: 'black'
    DropArea {
        id: dropArea
        keys: ['kvsExpression']
        anchors.fill: parent
        onDropped: drop => {
            if (drop.source) {
                drop.source.parent = root;
                drop.source.x = -drop.source.wingWidth;
                drop.source.y = 0;
                root.width = drop.source.width - drop.source.wingWidth;
                root.height = drop.source.height;
                root.parent.layoutContents();
                drop.accept();
            }
        }
    }
}