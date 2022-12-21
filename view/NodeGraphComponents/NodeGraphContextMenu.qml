import QtQuick
import QtQuick.Controls
import Python.NodeClassHelper  // qmllint disable import
import "../script/component-creation.js" as ComponentCreation

Menu {
    id: root
    property var nodeActions: new Map()
    property var nodeCategoryInfo: undefined
    property var scene: undefined
    // qmllint disable import type
    NodeClassHelper {
        id: nodeClassHelper
    }
    // qmllint enable import type
    TextField {
        id: searchInput
        placeholderText: qsTr('Search...')
        focus: true
    }
    Component.onCompleted: () => {
        this.createNodeActions();
        this.nodeCategoryInfo = nodeClassHelper.get_node_category_info();
        this.build();
    }

    function createNodeActions() {
        for (const nodeClassName of nodeClassHelper.get_all_node_class_names()) {
            const nodeShowName = nodeClassHelper.get_node_class_show_name(nodeClassName);
            new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/NodeAction.qml', this, {
                "nodeClassName": nodeClassName,
                "text": nodeShowName
            }, action => {
                this.nodeActions[action.nodeClassName] = action;
                action.triggered.connect(() => {
                        this.scene.createNode(action.nodeClassName, (this.parent.contentX + this.x) / this.scene.currentZoom, (this.parent.contentY + this.y) / this.scene.currentZoom);
                    });
            });
        }
    }

    function buildAndPopup() {
        this.build();
        this.popup();
    }

    function build(filterText = '') {
        this.clear();
        const buildFunction = (data, parentMenu) => {
            for (const itemName in data) {
                const item = data[itemName];
                if (typeof item === 'boolean') {
                    parentMenu.addAction(this.nodeActions[itemName]);
                } else if (typeof item === 'object') {
                    new ComponentCreation.ComponentCreation('qrc:/view/NodeGraphComponents/NodeGraphSubContextMenu.qml', parentMenu, {
                        "title": itemName
                    }, menu => {
                        parentMenu.addMenu(menu);
                        buildFunction(item, menu);
                    });
                }
            }
        };
        if (filterText) {
        } else {
            buildFunction(this.nodeCategoryInfo, this);
        }
    }

    function clear() {
        while (true) {
            if (this.actionAt(1)) {
                this.takeAction(1);
            } else if (this.itemAt(1)) {
                this.takeItem(1);
            } else if (this.menuAt(1)) {
                this.takeMenu(1);
            } else {
                break;
            }
        }
    }
}
