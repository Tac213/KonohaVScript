import QtQuick

DropArea {
    id: root
    required property int index
    property bool isBlock: true
    property string snappingNodeID: ''
    x: 0
    height: 40
    keys: ['kvsStatement']
    onDropped: drop => {
        if (this.snappingNodeID) {
            return;
        }
        if (drop.source) {
            drop.accept();
        }
    }
    Rectangle {
        anchors.fill: parent
        color: 'Aquamarine'
        visible: parent.containsDrag
    }

    function getNode() {
        const node = this.parent;
        return node;
    }

    function isSnappingStatementNode() {
        return this.snappingNodeID !== '';
    }

    function getSnappingStatementNode() {
        if (!this.snappingNodeID) {
            return undefined;
        }
        return this.getNode().getScene().getNode(this.snappingNodeID);
    }
}
