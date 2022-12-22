import QtQuick
import QtQuick.Layouts
import '.' as NodeGraphItems

Item {
    id: root
    width: contentLayout.width + this.wingWidth + this.contentOffset * 2
    height: 100
    required property var model
    property string nodeID: model.node_id
    property string nodeClassName: model.node_class_name
    property real wingWidth: 20
    property real contentOffset: 15
    property var contentTexts: []
    property var contentArgs: []

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
            // x: root.ingWidth
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
        x: root.wingWidth + root.contentOffset
        y: root.height / 2 - this.height / 2
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
    }

    Component.onCompleted: () => {
        this.createContent();
    }

    function createContent() {
        const [textList, argList] = this.parseNodeDescription();
        textList.forEach((text, idx) => {
            if (text) {
                const textElement = Qt.createQmlObject(
                    `import QtQuick; Text { text: '${text}'; color: 'white'; font.pixelSize: 24}`,
                    contentLayout,
                    `${this.nodeClassName}_${this.nodeID}_ContentText_${idx}_${text}`,
                );
                this.contentTexts.push(textElement);
            }
            if (idx < argList.length) {
                const argName = argList[idx];
                const argElement = Qt.createQmlObject(
                    `import '.'; ExpressionNodeShape { width: 100; height: 60; fillColor: 'white'; strokeColor: 'black'}`,
                    contentLayout,
                    `${this.nodeClassName}_${this.nodeID}_ContentArg_${idx}_${argName}`,
                );
                this.contentArgs.push(argElement);
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
}
