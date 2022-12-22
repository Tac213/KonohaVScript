import QtQuick
import Python.GraphModels  // qmllint disable import

Flickable {
    id: root
    clip: true
    contentWidth: scene.width
    contentHeight: scene.height
    contentX: 0.5 * scene.width - 0.5 * this.width
    contentY: 0.5 * scene.height - 0.5 * this.height
    NodeGraphScene {
        id: scene
    }
    // qmllint disable import type
    ScriptGraph {
        id: graph
    }
    // qmllint enable import type
    NodeGraphHandler {
        id: handler
        scene: scene
        graph: graph
        view: root
    }
    NodeGraphContextMenu {
        id: nodeGraphContextMenu
        scene: scene
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onWheel: event => {
            root.zoom(event.angleDelta.y > 0, event.x, event.y);
            event.accepted = true;
        }
        onClicked: event => {
            if (event.button === Qt.RightButton) {
                nodeGraphContextMenu.buildAndPopup();
                event.accepted = true;
            }
        }
    }

    function zoom(bigger, posX, posY) {
        let targetZoom = scene.currentZoom;
        if (bigger) {
            targetZoom += scene.zoomStride;
        } else {
            targetZoom -= scene.zoomStride;
        }
        targetZoom = Math.min(Math.max(targetZoom, scene.minZoom), scene.maxZoom);
        scene.currentZoom = targetZoom;
        scene.scaler.xScale = targetZoom;
        scene.scaler.yScale = targetZoom;
        this.resizeContent(scene.width * scene.currentZoom, scene.height * scene.currentZoom, Qt.point(posX, posY));
        this.returnToBounds();
    }
}
