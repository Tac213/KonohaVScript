import QtQuick
import QtQuick.Layouts
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
    RowLayout {
        id: contentLayout
        x: root.wingWidth + root.contentXMargin
        y: root.height / 2 - this.height / 2
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
        onReleased: event => {
            if (this.parent.Drag.target) {
                const action = this.parent.Drag.drop();
                if (action === Qt.MoveAction) {
                }
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
        this.height = height + this.contentYMargin * 2;
        let contentX = this.wingWidth + this.contentXMargin;
        for (const content of contents) {
            content.x = contentX;
            content.y = this.height / 2 - content.height / 2;
            contentX += content.width;
        }
    }
}
