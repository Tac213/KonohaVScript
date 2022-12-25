import QtQuick
import "."

ExpressionNodeShape {
    id: root
    required property int index
    required property string argName
    property bool enableSnap: true
    property string snappingExpressionNodeID: ''
    width: 100
    height: 60
    fillColor: dropArea.containsDrag ? 'Aquamarine' : 'white'
    strokeColor: 'black'
    DropArea {
        id: dropArea
        keys: ['kvsExpression']
        anchors.fill: parent
        onDropped: drop => {
            if (!this.parent.enableSnap) {
                return;
            }
            if (drop.source) {
                drop.accept();
            }
        }
    }

    function isSnappingExpressionNode() {
        return !this.enableSnap;
    }

    function getNode() {
        return this.parent;
    }

    function getSnappingExpressionNode() {
        if (this.enableSnap) {
            return undefined;
        }
        return this.getNode().getScene().getNode(this.snappingExpressionNodeID);
    }
}
