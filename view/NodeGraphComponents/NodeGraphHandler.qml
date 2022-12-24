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

    function snapArgument(expressionNode, argElement) {
        if (expressionNode.model.is_statement) {
            return;
        }
        if (expressionNode.snapped) {
            return;
        }
        expressionNode.parent = argElement;
        expressionNode.x = -expressionNode.wingWidth;
        expressionNode.y = 0;
        expressionNode.snapped = true;
        argElement.width = expressionNode.width - expressionNode.wingWidth;
        argElement.height = expressionNode.height;
        argElement.parent.layoutContents();
        const parentNode = argElement.getNode();
        parentNode.model.add_input_argument(argElement.argName, expressionNode.nodeID);
        expressionNode.updateModelPos();
    }

    function unsnapArgument(expressionNode) {
        if (expressionNode.model.is_statement) {
            return;
        }
        if (!expressionNode.snapped) {
            return;
        }
        const parentNode = expressionNode.getSnappingNode();
        const argElement = expressionNode.parent;
        const scenePos = this.scene.mapFromItem(expressionNode.parent, expressionNode.x, expressionNode.y);
        expressionNode.parent = this.scene;
        expressionNode.x = scenePos.x;
        expressionNode.y = scenePos.y;
        expressionNode.snapped = false;
        parentNode.model.remove_input_argument(argElement.argName);
        expressionNode.updateModelPos();
    }
}
