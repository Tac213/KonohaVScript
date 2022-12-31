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
    property var blockContents: []  // {index, contentTexts, contentArgs, snapIndicator}
    property var contentTexts: []
    property var contentArgs: []
    property real minimumWidth: 200
    property real minimumHeight: 100
    property real minimumBlockHeight: 40
    property bool snapped: false
    property string nextNodeID: ''
    property var blockNextNodeID: new Map()

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
            property bool isBlock: false
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

        function onNodeBlockDescriptionsChanged(previousDescriptions) {
            root.updateBlockContents(previousDescriptions);
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
                        const isBlock = this.parent.Drag.target.isBlock;
                        const blockIndex = this.parent.Drag.target.index;
                        lowerNode.getHandler().snapStatement(upperNode, lowerNode, isBlock, blockIndex);
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
        this.createBlockContent();
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

    function createBlockContent() {
        let total = 0;
        let current = 0;
        this.model.node_block_descriptions.forEach((blockDescription, index) => {
                this.blockContents.push({
                        "index": index,
                        "contentTexts": [],
                        "contentArgs": [],
                        "snapIndicator": undefined
                    });
                const parseResult = this.parseNodeDescription(blockDescription);
                const textList = parseResult.textList;
                const argList = parseResult.argList;
                textList.forEach((text, idx) => {
                        if (text) {
                            new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentText.qml', root, {
                                "index": idx,
                                "text": text
                            }, textElement => {
                                this.blockContents[index].contentTexts.push(textElement);
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
                                this.blockContents[index].contentArgs.push(argElement);
                                current++;
                                if (current >= total) {
                                    this.layoutContents();
                                }
                            });
                            total++;
                        }
                    });
                new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/CodeBlockSnapIndicator.qml', root, {
                    "index": index
                }, snapIndicator => {
                    snapIndicator.z = this.z - 1;
                    this.blockContents[index].snapIndicator = snapIndicator;
                    current++;
                    if (current >= total) {
                        this.layoutContents();
                    }
                });
                total++;
            });
    }

    function updateContent(previousDescription) {
        const diffResult = this._diffNodeDescription(previousDescription, this.model.node_description);
        this._updateSingleContent(diffResult, this.contentTexts, this.contentArgs);
    }

    function updateBlockContents(previousDescriptions) {
        const diffResult = this._diffNodeBlockDescriptions(previousDescriptions, this.model.node_block_descriptions);
        if (diffResult === null) {
            return;
        }
        if (diffResult.diffRows) {
            for (const diffRowInfo of diffResult.diffRows) {
                this._updateSingleContent(diffRowInfo, this.blockContents[diffRowInfo.index].contentTexts, this.blockContents[diffRowInfo.index].contentArgs);
            }
        }
        if (diffResult.deleteRows) {
            const needDeleteBlockContentIndices = [];
            this.blockContents.forEach((blockContent, index) => {
                    for (const deleteRowInfo of diffResult.deleteRows) {
                        if (blockContent.index === deleteRowInfo.index) {
                            needDeleteBlockContentIndices.push(index);
                            break;
                        }
                    }
                });
            needDeleteBlockContentIndices.sort();
            let deletedCount = 0;
            for (const index of needDeleteBlockContentIndices) {
                let deletedBlockContent = this.blockContents.splice(index - deletedCount, 1);
                deletedBlockContent = deletedBlockContent[0];
                while (deletedBlockContent.contentTexts.length) {
                    const textElement = deletedBlockContent.contentTexts.pop();
                    textElement.destroy();
                }
                while (deletedBlockContent.contentArgs.length) {
                    const argElement = deletedBlockContent.contentArgs.pop();
                    if (argElement.isSnappingExpressionNode()) {
                        this.getHandler().unsnapArgument(argElement.getSnappingExpressionNode());
                    }
                    argElement.destroy();
                }
                const snapIndicator = deletedBlockContent.snapIndicator;
                if (snapIndicator.isSnappingStatementNode()) {
                    this.getHandler().unsnapStatement(snapIndicator.getSnappingStatementNode());
                }
                snapIndicator.destroy();
                deletedCount += 1;
            }
        }
        if (diffResult.moveRows) {
            for (const moveRowInfo of diffResult.moveRows) {
            }
            for (const moveRowInfo of diffResult.moveRows) {
                this.model.node_block_descriptions.forEach((description, index) => {
                        if (description === moveRowInfo.description) {
                            let blockContent;
                            for (const candidate of this.blockContents) {
                                if (candidate.index === moveRowInfo.previousIndex) {
                                    blockContent = candidate;
                                    break;
                                }
                            }
                            blockContent.index = moveRowInfo.currentIndex;
                            blockContent.snapIndicator.index = moveRowInfo.currentIndex;
                            if (diffResult.deleteRows) {
                                for (const deleteRowInfo of diffResult.deleteRows) {
                                    if (blockContent.index >= deleteRowInfo.index) {
                                        blockContent.index++;
                                        blockContent.snapIndicator.index++;
                                    }
                                }
                            }
                            if (diffResult.newRows) {
                                for (const newRowInfo of diffResult.newRows) {
                                    if (blockContent.index >= newRowInfo.index) {
                                        blockContent.index--;
                                        blockContent.snapIndicator.index--;
                                    }
                                }
                            }
                        }
                    });
            }
        }
        if (diffResult.deleteRows) {
            for (const deleteRowInfo of diffResult.deleteRows) {
                for (const blockContent of this.blockContents) {
                    if (blockContent.index >= deleteRowInfo.index) {
                        blockContent.index--;
                        blockContent.snapIndicator.index--;
                    }
                }
            }
        }
        let hasNewRows = false;
        if (diffResult.newRows) {
            for (const newRowInfo of diffResult.newRows) {
                hasNewRows = true;
                for (const blockContent of this.blockContents) {
                    if (blockContent.index >= newRowInfo.index) {
                        blockContent.index++;
                        blockContent.snapIndicator.index++;
                    }
                }
            }
            let total = 0;
            let current = 0;
            for (const newRowInfo of diffResult.newRows) {
                this.blockContents.push({
                        "index": newRowInfo.index,
                        "contentTexts": [],
                        "contentArgs": [],
                        "snapIndicator": undefined
                    });
                const blockContent = this.blockContents[this.blockContents.length - 1];
                const parseResult = this.parseNodeDescription(newRowInfo.description);
                const textList = parseResult.textList;
                const argList = parseResult.argList;
                textList.forEach((text, idx) => {
                        if (text) {
                            new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/NodeContentText.qml', root, {
                                "index": idx,
                                "text": text
                            }, textElement => {
                                blockContent.contentTexts.push(textElement);
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
                                blockContent.contentArgs.push(argElement);
                                current++;
                                if (current >= total) {
                                    this.layoutContents();
                                }
                            });
                            total++;
                        }
                    });
                new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/Items/CodeBlockSnapIndicator.qml', root, {
                    "index": blockContent.index
                }, snapIndicator => {
                    snapIndicator.z = this.z - 1;
                    blockContent.snapIndicator = snapIndicator;
                    current++;
                    if (current >= total) {
                        this.layoutContents();
                    }
                });
                total++;
            }
        }
        // handle snapIndicator index changed
        this.blockNextNodeID.clear();
        this.model.clear_block_next_node_id();
        for (const blockContent of this.blockContents) {
            const snapIndicator = blockContent.snapIndicator;
            if (!snapIndicator) {
                continue;
            }
            if (snapIndicator.snappingNodeID) {
                this.blockNextNodeID.set(snapIndicator.index, snapIndicator.snappingNodeID);
                this.model.add_block_next_node_id(snapIndicator.index, snapIndicator.snappingNodeID);
            }
        }
        if (!diffResult.diffRows && !hasNewRows) {
            this.layoutContents();
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

    function _diffNodeBlockDescriptions(previousDescriptions, currentDescriptions) {
        // diff multi-block(if-else) and single-block(for while with function)
        const diffOneRow = (prevDesc, currDesc, rowIndex) => {
            const diffResult = this._diffNodeDescription(prevDesc, currDesc);
            if (diffResult.deleteTexts.length || diffResult.newTexts.length || diffResult.deleteArgs.length || diffResult.newArgs.length || diffResult.moveArgs.length) {
                return {
                    "index": rowIndex,
                    "deleteTexts": diffResult.deleteTexts,
                    "newTexts": diffResult.newTexts,
                    "deleteArgs": diffResult.deleteArgs,
                    "newArgs": diffResult.newArgs,
                    "moveArgs": diffResult.moveArgs
                };
            }
            return null;
        };
        const deleteRows = [];
        const newRows = [];
        const moveRows = [];
        const diffRows = [];
        if (previousDescriptions.length === 1 || currentDescriptions.length === 1) {
            if (previousDescriptions.length === currentDescriptions.length) {
                const rowDiff = diffOneRow(previousDescriptions[0], currentDescriptions[0], 0);
                if (rowDiff) {
                    diffRows.push(rowDiff);
                    return {
                        "diffRows": diffRows
                    };
                }
                return null;
            } else if (previousDescriptions.length > currentDescriptions.length) {
                for (const idx of Array(previousDescriptions.length - currentDescriptions.length).keys()) {
                    deleteRows.push({
                            "index": idx + 1
                        });
                }
                return {
                    "deleteRows": deleteRows
                };
            }
            for (const idx of Array(currentDescriptions.length - previousDescriptions.length).keys()) {
                newRows.push({
                        "index": idx + 1,
                        "description": currentDescriptions[idx + 1]
                    });
            }
            return {
                "newRows": newRows
            };
        }
        // diff multi-block(if-else)
        const getArgs = descs => {
            const args = [];
            for (const desc of descs) {
                const parseResult = this.parseNodeDescription(desc);
                if (parseResult.argList.length) {
                    args.push(parseResult.argList[0]);  // there is only one argument in 'if' or 'else-if'
                } else {
                    args.push('');  // should be 'else'
                }
            }
            return args;
        };
        const previousArgs = getArgs(previousDescriptions);
        const currentArgs = getArgs(currentDescriptions);
        previousArgs.forEach((argName, index) => {
                if (!currentArgs.includes(argName)) {
                    deleteRows.push({
                            "index": index
                        });
                }
            });
        currentArgs.forEach((argName, index) => {
                if (!previousArgs.includes(argName)) {
                    newRows.push({
                            "index": index,
                            "description": currentDescriptions[index]
                        });
                } else {
                    const previousIndex = previousArgs.indexOf(argName);
                    if (previousIndex !== index) {
                        moveRows.push({
                                "description": currentDescriptions[index],
                                "previousIndex": previousIndex,
                                "currentIndex": index
                            });
                    }
                }
            });
        return {
            "deleteRows": deleteRows,
            "newRows": newRows,
            "moveRows": moveRows
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
        const allBlockHeight = this.layoutBlockContents();
        this.contentTexts.sort((a, b) => a.index - b.index);
        this.contentArgs.sort((a, b) => a.index - b.index);
        const handleResult = this._handleSingleContent(this.contentTexts, this.contentArgs);
        const heightDiff = handleResult.height - this.height;
        if (allBlockHeight === 0) {
            this.width = handleResult.width;
            this.height = handleResult.height;
        }
        let contentX = this.wingWidth + this.contentXMargin;
        for (const content of handleResult.contents) {
            content.x = contentX;
            content.y = allBlockHeight + handleResult.height / 2 - content.height / 2;
            contentX += content.width;
        }
        const nextNode = this.getNextNode();
        if (nextNode) {
            nextNode.y = this.height;
            nextNode.updateModelPos();
        }
    }

    function layoutBlockContents() {
        this.blockContents.sort((a, b) => a.index - b.index);
        const blockInfos = this.blockInfos.slice(0, this.blockContents.length);
        let width = 0;
        let height = 0;
        this.blockContents.forEach((blockContent, index) => {
                if (index >= blockInfos.length) {
                    blockInfos.push({
                            "contentWidth": 0,
                            "contentHeight": 0,
                            "blockHeight": 0
                        });
                }
                const blockInfo = blockInfos[index];
                blockContent.contentTexts.sort((a, b) => a.index - b.index);
                blockContent.contentArgs.sort((a, b) => a.index - b.index);
                const handleResult = this._handleSingleContent(blockContent.contentTexts, blockContent.contentArgs);
                blockInfo.contentWidth = handleResult.width - this.wingWidth;
                blockInfo.contentHeight = handleResult.height;
                width = Math.max(width, handleResult.width);
                let contentX = this.wingWidth + this.contentXMargin;
                for (const content of handleResult.contents) {
                    content.x = contentX;
                    content.y = height + handleResult.height / 2 - content.height / 2;
                    contentX += content.width;
                }
                height += handleResult.height;
                const blockWidth = this.getBlockWidth();
                blockContent.snapIndicator.x = this.wingWidth + blockWidth;
                blockContent.snapIndicator.y = height;
                blockContent.snapIndicator.width = blockInfo.contentWidth - blockWidth;
                let blockHeight = this.minimumBlockHeight;
                let nextNode = this.getBlockNextNode(index);
                if (nextNode) {
                    nextNode.y = height;
                    nextNode.updateModelPos();
                }
                while (nextNode) {
                    blockHeight += nextNode.height;
                    nextNode = nextNode.getNextNode();
                }
                blockInfo.blockHeight = blockHeight;
                height += blockInfo.blockHeight;
            });
        this.width = width;
        this.blockInfos = blockInfos;
        return height;
    }

    function _updateSingleContent(diffResult, contentTexts, contentArgs) {
        const deleteTexts = diffResult.deleteTexts;
        const newTexts = diffResult.newTexts;
        const deleteArgs = diffResult.deleteArgs;
        const newArgs = diffResult.newArgs;
        const moveArgs = diffResult.moveArgs;
        const needDeleteTextElementIndices = [];
        contentTexts.forEach((textElement, index) => {
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
            let deletedText = contentTexts.splice(index - deletedCount, 1);
            deletedText = deletedText[0];
            deletedText.destroy();
            deletedCount += 1;
        }
        for (const deleteTextInfo of deleteTexts) {
            for (const textElement of contentTexts) {
                if (textElement.index >= deleteTextInfo.index) {
                    textElement.index--;
                }
            }
        }
        const needDeleteArgElementIndices = [];
        contentArgs.forEach((argElement, index) => {
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
            let deletedArg = contentArgs.splice(index - deletedCount, 1);
            deletedArg = deletedArg[0];
            if (deletedArg.isSnappingExpressionNode()) {
                this.getHandler().unsnapArgument(deletedArg.getSnappingExpressionNode());
            }
            deletedArg.destroy();
            deletedCount += 1;
        }
        for (const moveArgInfo of moveArgs) {
            for (const argElement of contentArgs) {
                if (argElement.argName === moveArgInfo.argName) {
                    argElement.index = moveArgInfo.currentIndex;
                    for (const deleteArgInfo of deleteArgs) {
                        if (argElement.index >= deleteArgInfo.index) {
                            argElement.index++;
                        }
                    }
                    for (const newArgInfo of newArgs) {
                        if (argElement.index >= newArgInfo.index) {
                            argElement.index--;
                        }
                    }
                    break;
                }
            }
        }
        for (const deleteArgInfo of deleteArgs) {
            for (const argElement of contentArgs) {
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
                contentTexts.push(textElement);
                current++;
                if (current >= total) {
                    this.layoutContents();
                }
            });
            total++;
            for (const textElement of contentTexts) {
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
                contentArgs.push(argElement);
                current++;
                if (current >= total) {
                    this.layoutContents();
                }
            });
            total++;
            for (const argElement of contentArgs) {
                if (argElement.index >= newArgInfo.index) {
                    argElement.index++;
                }
            }
        }
    }

    function _handleSingleContent(contentTexts, contentArgs) {
        let textIndex = 0;
        let argIndex = 0;
        const contents = [];
        let width = 0;
        let height = this.minimumHeight - this.contentYMargin * 2;
        while (textIndex < contentTexts.length || argIndex < contentArgs.length) {
            const currentText = contentTexts[textIndex];
            const currentArg = contentArgs[argIndex];
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
        const targetWidth = Math.max(this.wingWidth + width + this.contentXMargin * 2, this.minimumWidth);
        const targetHeight = height + this.contentYMargin * 2;
        return {
            "contents": contents,
            "width": targetWidth,
            "height": targetHeight
        };
    }

    function getBlockWidth() {
        if (!this.model.is_code_block) {
            return undefined;
        }
        return bodyLoader.item ? bodyLoader.item.blockWidth : 50;
    }

    function getBlockOffset() {
        if (!this.model.is_code_block) {
            return undefined;
        }
        return bodyLoader.item ? bodyLoader.item.blockOffset : 5;
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

    function getBlockNextNode(index) {
        if (!this.model.is_code_block) {
            return undefined;
        }
        const nextNodeID = this.blockNextNodeID.get(index);
        if (!nextNodeID) {
            return undefined;
        }
        const scene = this.getScene();
        return scene.getNode(nextNodeID);
    }
}
