import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property real pinOffset: 30
    property real pinWidth: 32
    property real pinHeight: 16
    property real blockOffset: 5
    property real blockPinOffset: this.pinOffset + 20 + this.blockOffset  // 20 is wingWidth
    property real blockWidth: 50
    property real lastWidth: 100
    property real lastHeight: 30
    property alias fillColor: bodyPath.fillColor
    property alias strokeColor: bodyPath.strokeColor
    property var blockInfos: []  // {contentWidth, contentHeight, blockHeight}
    property var basePathElements: []
    property var dynamicPathElements: []
    property alias heightBinder: heightBinder
    ShapePath {
        id: bodyPath
        fillColor: 'LightSlateGray'
        startX: 0
        startY: 0
        PathLine {
            x: root.lastWidth
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0)
        }
        PathLine {
            x: root.lastWidth
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0) + root.lastHeight
        }
        PathLine {
            x: bodyPath.startX + root.pinOffset + root.pinWidth
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0) + root.lastHeight
        }
        PathLine {
            x: bodyPath.startX + root.pinOffset + root.pinWidth / 2
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0) + root.lastHeight + root.pinHeight
        }
        PathLine {
            x: bodyPath.startX + root.pinOffset
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0) + root.lastHeight
        }
        PathLine {
            x: bodyPath.startX
            y: root.blockInfos.reduce((partialSum, a) => partialSum + a.contentHeight + a.blockHeight, 0) + root.lastHeight
        }
        PathLine {
            x: bodyPath.startX
            y: bodyPath.startY
        }
    }
    Binding {
        id: heightBinder
        property: 'height'
        value: root.height
    }
    Component.onCompleted: () => {
        for (const [_, path] of Object.entries(bodyPath.pathElements)) {
            this.basePathElements.push(path);
        }
    }

    onBlockInfosChanged: () => {
        if (!this.basePathElements.length) {
            return;
        }
        this.update();
    }

    function update() {
        this.clearDynamicPathElements();
        const blockPathElements = [];
        let currentHeight = bodyPath.startY;
        this.blockInfos.forEach((blockInfo, index) => {
                if (index === 0) {
                    blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.pinOffset}; y: ${currentHeight}}`, bodyPath));
                    blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.pinOffset + this.pinWidth / 2}; y: ${currentHeight + this.pinHeight}}`, bodyPath));
                    blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.pinOffset + this.pinWidth}; y: ${currentHeight}}`, bodyPath));
                    blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${blockInfo.contentWidth}; y: ${currentHeight}}`, bodyPath));
                } else {
                    blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${blockInfo.contentWidth}; y: ${currentHeight}}`, bodyPath));
                }
                currentHeight += blockInfo.contentHeight;
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${blockInfo.contentWidth}; y: ${currentHeight}}`, bodyPath));
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.blockWidth + this.blockPinOffset + this.pinWidth}; y: ${currentHeight}}`, bodyPath));
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.blockWidth + this.blockPinOffset + this.pinWidth / 2}; y: ${currentHeight + this.pinHeight}}`, bodyPath));
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.blockWidth + this.blockPinOffset}; y: ${currentHeight}}`, bodyPath));
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.blockWidth}; y: ${currentHeight}}`, bodyPath));
                currentHeight += blockInfo.blockHeight;
                blockPathElements.push(Qt.createQmlObject(`import QtQuick; PathLine {x: ${bodyPath.startX + this.blockWidth}; y: ${currentHeight}}`, bodyPath));
            });
        bodyPath.pathElements = blockPathElements.concat(this.basePathElements);
        this.dynamicPathElements = blockPathElements;
        this.height = currentHeight + this.lastHeight;
    }

    function clearDynamicPathElements() {
        while (this.dynamicPathElements.length) {
            const pathElement = this.dynamicPathElements.pop();
            pathElement.destroy();
        }
    }
}
