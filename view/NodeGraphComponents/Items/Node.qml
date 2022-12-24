import QtQuick
import "." as NodeGraphItems
import "../../script/component-creation.js" as ComponentCreation

Item {
    id: root
    width: this.minimumWidth
    height: this.minimumHeight
    required property var model
    property string nodeID: model.node_id
    property string nodeClassName: model.node_class_name
    property real wingWidth: 20
    property real contentXMargin: 15
    property real contentYMargin: 20
    property var contentTexts: []
    property var contentArgs: []
    property var minimumWidth: 200
    property real minimumHeight: 100
    property bool snapped: false
    property string nextNodeID: ''

    Drag.active: mouseArea.drag.active
    Drag.hotSpot.x: this.wingWidth
    Drag.hotSpot.y: 0
    Drag.keys: [model.is_statement ? 'kvsStatement' : 'kvsExpression']

    Component {
        id: wing
        Rectangle {
            // id: wing
            // width: root.wingWidth
            // height: root.height
            color: 'LightCoral'
        }
    }
    Component {
        id: statementSnapIndicator
        DropArea {
            x: 0
            height: 40
            keys: ['kvsStatement']
            onDropped: drop => {
                if (this.getNode().nextNodeID) {
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
                const loader = this.parent;
                return loader.parent;
            }
        }
    }
    Component {
        id: statementBody
        NodeGraphItems.StatementNodeShape {
            // id: body
            // x: root.wingWidth
            y: 0
            // width: root.width - root.wingWidth
            // height: root.height
            fillColor: 'LightSlateGray'
        }
    }
    Component {
        id: expressionBody
        NodeGraphItems.ExpressionNodeShape {
            // id: body
            // x: root.wingWidth
            y: 0
            // width: root.width - root.wingWidth
            // height: root.height
            fillColor: 'LightSlateGray'
        }
    }
    Loader {
        id: wingLoader
        sourceComponent: root.model.is_statement ? wing : undefined
        onLoaded: () => {
            wingWidthBinder.target = this.item;
            wingHeightBinder.target = this.item;
        }
    }
    Loader {
        id: snapIndicatorLoader
        sourceComponent: root.model.is_statement ? statementSnapIndicator : undefined
        onLoaded: () => {
            snapIndicatorWidthBinder.target = this.item;
            snapIndicatorYBinder.target = this.item;
        }
    }
    Loader {
        id: bodyLoader
        sourceComponent: root.model.is_statement ? statementBody : expressionBody
        onLoaded: () => {
            bodyXBinder.target = this.item;
            bodyWidthBinder.target = this.item;
            bodyHeightBinder.target = this.item;
        }
    }
    Binding {
        id: wingWidthBinder
        property: 'width'
        value: root.wingWidth
    }
    Binding {
        id: wingHeightBinder
        property: 'height'
        value: root.height
    }
    Binding {
        id: snapIndicatorWidthBinder
        property: 'width'
        value: root.width
    }
    Binding {
        id: snapIndicatorYBinder
        property: 'y'
        value: root.height
    }
    Binding {
        id: bodyXBinder
        property: 'x'
        value: root.wingWidth
    }
    Binding {
        id: bodyWidthBinder
        property: 'width'
        value: root.width - root.wingWidth
    }
    Binding {
        id: bodyHeightBinder
        property: 'height'
        value: root.height
    }
    NodeGraphItems.NodeContextMenu {
        id: contextMenu
        node: root
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        drag.target: parent.snapped ? parent.getDragTarget() : parent
        preventStealing: true
        onReleased: event => {
            this.parent.updateModelPos();
            if (this.parent.Drag.target) {
                const action = this.parent.Drag.drop();
                if (action === Qt.MoveAction) {
                    if (this.parent.model.is_statement) {
                        const upperNode = this.parent.Drag.target.getNode();  // call getNode function on DropArea
                        const lowerNode = this.parent;
                        lowerNode.getHandler().snapStatement(upperNode, lowerNode);
                    } else {
                        const contentArgElement = this.parent.Drag.target.parent;
                        const expressionNode = this.parent;
                        expressionNode.getHandler().snapArgument(expressionNode, contentArgElement);
                    }
                }
            }
        }
        onClicked: event => {
            if (event.button === Qt.MiddleButton) {
                contextMenu.popup();
                event.accepted = true;
            }
        }
    }

    Component.onCompleted: () => {
        this.createContent();
    }

    function createContent() {
        const [textList, argList] = this.parseNodeDescription();
        let total = 0;
        let current = 0;
        textList.forEach((text, idx) => {
            if (text) {
                new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentText.qml', root, {
                    "index": idx,
                    "text": text
                }, textElement => {
                    this.contentTexts.push(textElement);
                    current++;
                    if (current >= total) {
                        this.layoutContents();
                    }
                });
                total++;
            }
            if (idx < argList.length) {
                const argName = argList[idx];
                new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentArgument.qml', root, {
                    "index": idx,
                    "argName": argName
                }, argElement => {
                    this.contentArgs.push(argElement);
                    current++;
                    if (current >= total) {
                        this.layoutContents();
                    }
                });
                total++;
            }
        });
    }

    function parseNodeDescription() {
        const inputArgsRE = /{{\s*[a-zA-Z_]+[0-9a-zA-Z_]*\s*}}/gm;
        const variableNameRE = /[a-zA-Z_]+[0-9a-zA-Z_]*/gm;
        const textList = this.model.node_description.split(inputArgsRE);
        const argList = [];
        let match = inputArgsRE.exec(this.model.node_description);
        while (match) {
            const inputArgSring = match[0];
            const variableName = variableNameRE.exec(inputArgSring)[0];
            argList.push(variableName);
            variableNameRE.lastIndex = 0;
            match = inputArgsRE.exec(this.model.node_description);
        }
        return [textList, argList];
    }

    function layoutContents() {
        this.contentTexts.sort((a, b) => a.index - b.index);
        this.contentArgs.sort((a, b) => a.index - b.index);
        let textIndex = 0;
        let argIndex = 0;
        const contents = [];
        let width = 0;
        let height = this.minimumHeight - this.contentYMargin * 2;
        while (textIndex < this.contentTexts.length || argIndex < this.contentArgs.length) {
            const currentText = this.contentTexts[textIndex];
            const currentArg = this.contentArgs[argIndex];
            if (currentText) {
                if (currentArg) {
                    if (currentText.index <= currentArg.index) {
                        contents.push(currentText);
                        textIndex++;
                        width += currentText.width;
                        height = Math.max(height, currentText.height);
                    } else {
                        contents.push(currentArg);
                        argIndex++;
                        width += currentArg.width;
                        height = Math.max(height, currentArg.height);
                    }
                } else {
                    contents.push(currentText);
                    textIndex++;
                    width += currentText.width;
                    height = Math.max(height, currentText.height);
                }
            } else if (currentArg) {
                contents.push(currentArg);
                argIndex++;
                width += currentArg.width;
                height = Math.max(height, currentArg.height);
            }
        }
        this.width = Math.max(this.wingWidth + width + this.contentXMargin * 2, this.minimumWidth);
        const targetHeight = height + this.contentYMargin * 2;
        const heightDiff = targetHeight - this.height;
        this.height = targetHeight;
        let contentX = this.wingWidth + this.contentXMargin;
        for (const content of contents) {
            content.x = contentX;
            content.y = this.height / 2 - content.height / 2;
            contentX += content.width;
        }
        const nextNode = this.getNextNode();
        if (nextNode) {
            nextNode.y += heightDiff;
            nextNode.updateModelPos();
        }
    }

    function getScene() {
        let candidate = this.parent;
        while (candidate) {
            if (candidate.objectName === 'kvsScene') {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    function getHandler() {
        const scene = this.getScene();
        return scene ? scene.getHandler() : null;
    }

    function updateModelPos() {
        this.model.pos_x = this.x;
        this.model.pos_y = this.y;
    }

    function getDragTarget() {
        if (!this.snapped) {
            return this;
        }
        let candidate = this.getSnappingNode();
        while (candidate) {
            if (!candidate.snapped) {
                return candidate;
            }
            candidate = candidate.getSnappingNode();
        }
        return null;
    }

    function getSnappingNode() {
        if (!this.snapped) {
            return undefined;
        }
        if (this.model.is_statement) {
            return this.parent;
        }
        return this.parent.parent;
    }

    function getNextNode() {
        if (!this.nextNodeID) {
            return undefined;
        }
        const scene = this.getScene();
        return scene.getNode(this.nextNodeID);
    }
}
