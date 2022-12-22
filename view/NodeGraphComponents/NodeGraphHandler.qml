import QtQml

QtObject {
    id: root
    required property var scene
    required property var graph
    required property var view

    function createNode(nodeClassName, posX, posY, nodeID = undefined) {
        if (!this.graph.check_node_id(nodeID)) {
            nodeID = this.graph.generate_node_id();
        }
        const nodeModel = Qt.createQmlObject(`import Python.NodeModels; ${nodeClassName} { node_id: '${nodeID}'; pos_x: ${posX}; pos_y: ${posY}}`, this.graph, `${nodeClassName}_${nodeID}`);
        this.graph.add_node(nodeID, nodeModel);
        this.scene.createNode(nodeModel);
    }
}
