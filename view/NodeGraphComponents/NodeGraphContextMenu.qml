import QtQuick
import QtQuick.Controls
import Python.NodeClassHelper  // qmllint disable import
import "../script/component-creation.js" as ComponentCreation

Menu {
    id: root
    property var nodeActions: new Map()
    property var nodeCategoryInfo: undefined
    required property var handler
    // qmllint disable import type
    NodeClassHelper {
        id: nodeClassHelper
    }
    // qmllint enable import type
    TextField {
        id: searchInput
        placeholderText: qsTr('Search...')
        focus: true
        onTextEdited: () => {
            root.build(this.text);
        }
    }
    Component.onCompleted: () => {
        this.createNodeActions();
        this.nodeCategoryInfo = nodeClassHelper.get_node_category_info();
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
                        this.handler.createNode(action.nodeClassName, (this.parent.contentX + this.x) / this.handler.scene.currentZoom, (this.parent.contentY + this.y) / this.handler.scene.currentZoom);
                    });
            });
        }
    }

    function buildAndPopup() {
        searchInput.text = '';
        this.build();
        this.popup();
    }

    function build(filterText = '') {
        this.clear();
        const buildFunction = (data, parentMenu) => {
            for (const [itemName, item] of Object.entries(data)) {
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
            let allActions = {};
            const filterItems = data => {
                let res = {};
                for (const [itemName, item] of Object.entries(data)) {
                    if (typeof item === 'boolean') {
                        if (this._filterAction(filterText, itemName)) {
                            res[itemName] = item;
                            allActions[itemName] = item;
                        }
                    } else if (typeof item === 'object') {
                        const childRes = filterItems(item);
                        if (Object.keys(childRes).length) {
                            res[itemName] = childRes;
                        }
                    }
                }
                return res;
            };
            let filteredItems = filterItems(this.nodeCategoryInfo);
            if (Object.keys(allActions).length <= 10) {
                filteredItems = allActions;
            }
            buildFunction(filteredItems, this);
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

    function _filterAction(filterText, actionName) {
        const lowerFilterText = filterText.toLowerCase();
        const lowerActionName = actionName.toLowerCase();
        return lowerActionName.includes(lowerFilterText);
    }
}
