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
        argElement.snappingExpressionNodeID = expressionNode.nodeID;
        let snappingNode = argElement.getNode();
        snappingNode.layoutContents();
        while (!snappingNode.model.is_statement && snappingNode.snapped) {
            const parentArgElement = snappingNode.parent;
            parentArgElement.width = snappingNode.width - snappingNode.wingWidth;
            parentArgElement.height = snappingNode.height;
            snappingNode = snappingNode.getSnappingNode();
            snappingNode.layoutContents();
        }
        while (snappingNode) {
            snappingNode.layoutContents();
            snappingNode = snappingNode.getSnappingNode();
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
        argElement.snappingExpressionNodeID = '';
        parentNode.model.remove_input_argument(argElement.argName);
        expressionNode.updateModelPos();
    }

    function snapStatement(upperNode, lowerNode, isBlock, blockIndex) {
        if (!upperNode.model.is_statement || !lowerNode.model.is_statement) {
            return;
        }
        if (lowerNode.snapped) {
            return;
        }
        lowerNode.parent = upperNode;
        if (!isBlock) {
            lowerNode.x = 0;
            lowerNode.y = upperNode.height;
            upperNode.nextNodeID = lowerNode.nodeID;
            upperNode.model.next_node_id = lowerNode.nodeID;
        } else {
            const snapIndicator = upperNode.blockContents[blockIndex].snapIndicator;
            lowerNode.x = snapIndicator.x + upperNode.getBlockOffset();
            lowerNode.y = snapIndicator.y;
            snapIndicator.snappingNodeID = lowerNode.nodeID;
            upperNode.blockNextNodeID.set(blockIndex, lowerNode.nodeID);
            upperNode.model.add_block_next_node_id(blockIndex, lowerNode.nodeID);
            upperNode.layoutContents();
        }
        lowerNode.snapped = true;
        lowerNode.updateModelPos();
        let snappingNode = upperNode.getSnappingNode();
        while (snappingNode) {
            snappingNode.layoutContents();
            snappingNode = snappingNode.getSnappingNode();
        }
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
        if (upperNode.nextNodeID === lowerNode.nodeID) {
            upperNode.nextNodeID = '';
            upperNode.model.next_node_id = '';
        } else {
            let blockIndex;
            for (const [index, nodeID] of upperNode.blockNextNodeID) {
                if (nodeID === lowerNode.nodeID) {
                    blockIndex = index;
                    break;
                }
            }
            if (blockIndex !== undefined) {
                upperNode.blockNextNodeID.delete(blockIndex);
                upperNode.model.remove_block_next_node_id(blockIndex, lowerNode.nodeID);
            }
            // blockIndex may be different from blockContents, iterate for accurate snapIndicator
            let snapIndicator;
            for (const blockContent of upperNode.blockContents) {
                if (blockContent.snapIndicator.snappingNodeID === lowerNode.nodeID) {
                    snapIndicator = blockContent.snapIndicator;
                    break;
                }
            }
            if (snapIndicator) {
                snapIndicator.snappingNodeID = '';
            }
        }
        lowerNode.updateModelPos();
    }
}
