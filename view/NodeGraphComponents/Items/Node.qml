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
    property var blockInfos: []  // {contentWidth, contentHeight, blockHeight}
    property var blockContents: []  // {contentTexts, contentArgs}
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
        id: codeBlockBody
        NodeGraphItems.CodeBlockNodeShape {
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
        sourceComponent: root.model.is_statement ? (root.model.is_code_block ? codeBlockBody : statementBody) : expressionBody
        onLoaded: () => {
            bodyXBinder.target = this.item;
            bodyWidthBinder.target = this.item;
            if (root.model.is_code_block) {
                bodyBlockInfosBinder.target = this.item;
                this.item.heightBinder.target = root;
            } else {
                bodyHeightBinder.target = this.item;
            }
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
    Binding {
        id: bodyBlockInfosBinder
        property: 'blockInfos'
        value: root.blockInfos
    }
    Connections {
        target: root.model
        function onNodeDescriptionChanged(previousDescription) {
            root.updateContent(previousDescription);
        }
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
        const parseResult = this.parseNodeDescription();
        const textList = parseResult.textList;
        const argList = parseResult.argList;
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

    function updateContent(previousDescription) {
        const diffResult = this._diffNodeDescription(previousDescription, this.model.node_description);
        const deleteTexts = diffResult.deleteTexts;
        const newTexts = diffResult.newTexts;
        const deleteArgs = diffResult.deleteArgs;
        const newArgs = diffResult.newArgs;
        const moveArgs = diffResult.moveArgs;
        const needDeleteTextElementIndices = [];
        this.contentTexts.forEach((textElement, index) => {
                for (const deleteTextInfo of deleteTexts) {
                    if (textElement.index === deleteTextInfo.index) {
                        needDeleteTextElementIndices.push(index);
                        break;
                    }
                }
            });
        needDeleteTextElementIndices.sort();
        let deletedCount = 0;
        for (const index of needDeleteTextElementIndices) {
            let deletedText = this.contentTexts.splice(index - deletedCount, 1);
            deletedText = deletedText[0];
            deletedText.destroy();
            deletedCount += 1;
        }
        for (const deleteTextInfo of deleteTexts) {
            for (const textElement of this.contentTexts) {
                if (textElement.index >= deleteTextInfo.index) {
                    textElement.index--;
                }
            }
        }
        const needDeleteArgElementIndices = [];
        this.contentArgs.forEach((argElement, index) => {
                for (const deleteArgInfo of deleteArgs) {
                    if (argElement.index === deleteArgInfo.index) {
                        needDeleteArgElementIndices.push(index);
                        break;
                    }
                }
            });
        needDeleteArgElementIndices.sort();
        deletedCount = 0;
        for (const index of needDeleteArgElementIndices) {
            let deletedArg = this.contentArgs.splice(index - deletedCount, 1);
            deletedArg = deletedArg[0];
            if (deletedArg.isSnappingExpressionNode()) {
                this.getHandler().unsnapArgument(deletedArg.getSnappingExpressionNode());
            }
            deletedArg.destroy();
            deletedCount += 1;
        }
        for (const moveArgInfo of moveArgs) {
            for (const argElement of this.contentArgs) {
                if (argElement.argName === moveArgInfo.argName) {
                    argElement.index = moveArgInfo.currentIndex;
                    for (const deleteArgInfo of deleteArgs) {
                        if (argElement.index >= deleteArgInfo.index) {
                            argElement.index++;
                        }
                    }
                    break;
                }
            }
        }
        for (const deleteArgInfo of deleteArgs) {
            for (const argElement of this.contentArgs) {
                if (argElement.index >= deleteArgInfo.index) {
                    argElement.index--;
                }
            }
        }
        let total = 0;
        let current = 0;
        for (const newTextInfo of newTexts) {
            new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentText.qml', root, {
                "index": newTextInfo.index,
                "text": newTextInfo.text
            }, textElement => {
                this.contentTexts.push(textElement);
                current++;
                if (current >= total) {
                    this.layoutContents();
                }
            });
            total++;
            for (const textElement of this.contentTexts) {
                if (textElement.index >= newTextInfo.index) {
                    textElement.index++;
                }
            }
        }
        for (const newArgInfo of newArgs) {
            new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentArgument.qml', root, {
                "index": newArgInfo.index,
                "argName": newArgInfo.argName
            }, argElement => {
                this.contentArgs.push(argElement);
                current++;
                if (current >= total) {
                    this.layoutContents();
                }
            });
            total++;
            for (const argElement of this.contentArgs) {
                if (argElement.index >= newArgInfo.index) {
                    argElement.index++;
                }
            }
        }
    }

    function _diffNodeDescription(previousDescription, currentDescription) {
        const previousParseResult = this.parseNodeDescription(previousDescription);
        const previousTextList = previousParseResult.textList;
        const previousArgList = previousParseResult.argList;
        const currentParseResult = this.parseNodeDescription(currentDescription);
        const currentTextList = currentParseResult.textList;
        const currentArgList = currentParseResult.argList;
        const deleteTexts = [];
        // It is hard to diff texts, which is buggy even if the accurate code is written.
        // Just simply remove all previous texts and create all new texts.
        previousTextList.forEach((text, index) => {
                if (!text) {
                    return;
                }
                deleteTexts.push({
                        "index": index,
                        "text": text
                    });
            });
        const newTexts = [];
        currentTextList.forEach((text, index) => {
                if (!text) {
                    return;
                }
                newTexts.push({
                        "index": index,
                        "text": text
                    });
            });
        // argNames are unique, which make them easier to diff.
        const deleteArgs = [];
        previousArgList.forEach((argName, index) => {
                if (!currentArgList.includes(argName)) {
                    deleteArgs.push({
                            "index": index,
                            "argName": argName
                        });
                }
            });
        const newArgs = [];
        const moveArgs = [];
        currentArgList.forEach((argName, index) => {
                if (!previousArgList.includes(argName)) {
                    newArgs.push({
                            "index": index,
                            "argName": argName
                        });
                } else {
                    const previousIndex = previousArgList.indexOf(argName);
                    if (previousIndex !== index) {
                        moveArgs.push({
                                "argName": argName,
                                "previousIndex": previousIndex,
                                "currentIndex": index
                            });
                    }
                }
            });
        return {
            "deleteTexts": deleteTexts,
            "newTexts": newTexts,
            "deleteArgs": deleteArgs,
            "newArgs": newArgs,
            "moveArgs": moveArgs
        };
    }

    function parseNodeDescription(node_description = undefined) {
        if (node_description === undefined) {
            node_description = this.model.node_description;
        }
        const inputArgsRE = /{{\s*[a-zA-Z_]+[0-9a-zA-Z_]*\s*}}/gm;
        const variableNameRE = /[a-zA-Z_]+[0-9a-zA-Z_]*/gm;
        const textList = node_description.split(inputArgsRE);
        const argList = [];
        let match = inputArgsRE.exec(node_description);
        while (match) {
            const inputArgSring = match[0];
            const variableName = variableNameRE.exec(inputArgSring)[0];
            argList.push(variableName);
            variableNameRE.lastIndex = 0;
            match = inputArgsRE.exec(node_description);
        }
        return {
            "textList": textList,
            "argList": argList
        };
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
