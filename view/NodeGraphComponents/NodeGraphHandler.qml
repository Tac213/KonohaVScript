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
        argElement.enableSnap = false;
        let parentNode = argElement.getNode();
        parentNode.layoutContents();
        while (!parentNode.model.is_statement && parentNode.snapped) {
            const parentArgElement = parentNode.parent;
            parentArgElement.width = parentNode.width - parentNode.wingWidth;
            parentArgElement.height = parentNode.height;
            parentNode = parentNode.getSnappingNode();
            parentNode.layoutContents();
        }
        argElement.getNode().model.add_input_argument(argElement.argName, expressionNode.nodeID);
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
        expressionNode.x = scenePos.x + 20;  // make some offset
        expressionNode.y = scenePos.y + 20;  // make some offset
        expressionNode.snapped = false;
        argElement.enableSnap = true;
        parentNode.model.remove_input_argument(argElement.argName);
        expressionNode.updateModelPos();
    }

    function snapStatement(upperNode, lowerNode) {
        if (!upperNode.model.is_statement || !lowerNode.model.is_statement) {
            return;
        }
        if (lowerNode.snapped) {
            return;
        }
        lowerNode.parent = upperNode;
        lowerNode.x = 0;
        lowerNode.y = upperNode.height;
        lowerNode.snapped = true;
        upperNode.nextNodeID = lowerNode.nodeID;
        upperNode.model.next_node_id = lowerNode.nodeID;
        lowerNode.updateModelPos();
    }

    function unsnapStatement(lowerNode) {
        if (!lowerNode.model.is_statement) {
            return;
        }
        if (!lowerNode.snapped) {
            return;
        }
        const upperNode = lowerNode.parent;
        this._unsnapStatement(upperNode, lowerNode);
    }

    function unsnapNextStatement(upperNode) {
        if (!upperNode.model.is_statement) {
            return;
        }
        const lowerNode = upperNode.getNextNode();
        if (!lowerNode) {
            return;
        }
        this._unsnapStatement(upperNode, lowerNode);
    }

    function _unsnapStatement(upperNode, lowerNode) {
        const scenePos = this.scene.mapFromItem(upperNode, lowerNode.x, lowerNode.y);
        lowerNode.parent = this.scene;
        lowerNode.x = scenePos.x + 20;  // make some offset
        lowerNode.y = scenePos.y + 20;  // make some offset
        lowerNode.snapped = false;
        upperNode.nextNodeID = '';
        upperNode.model.next_node_id = '';
        lowerNode.updateModelPos();
    }
}
