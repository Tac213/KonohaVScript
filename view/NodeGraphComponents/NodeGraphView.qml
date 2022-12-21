import QtQuick
import "Items" as NodeGraphItems

Flickable {
    id: root
    clip: true
    contentWidth: scene.width
    contentHeight: scene.height
    Item {
        id: scene
        width: 12000
        height: 12000
        transform: Scale {
            id: sceneScaler
            origin.x: 0
            origin.y: 0
        }
        property real currentZoom: 1.0
        property real minZoom: 0.2
        property real maxZoom: 2.0
        property real zoomStride: 0.1

        Canvas {
            id: grid
            anchors.fill: parent
            property int wgrid: 60
            onPaint: {
                const ctx = getContext('2d');
                ctx.lineWidth = 1;
                ctx.strokeStyle = 'black';
                ctx.beginPath();
                const nrows = height / this.wgrid;
                for (var i = 0; i < nrows + 1; i++) {
                    ctx.moveTo(0, this.wgrid * i);
                    ctx.lineTo(width, this.wgrid * i);
                }
                const ncols = width / this.wgrid;
                for (var j = 0; j < ncols + 1; j++) {
                    ctx.moveTo(this.wgrid * j, 0);
                    ctx.lineTo(this.wgrid * j, height);
                }
                ctx.closePath();
                ctx.stroke();
            }
        }
        Repeater {
            model: 500

            NodeGraphItems.Node {
                x: random(0, scene.width - 300)  // qmllint disable unqualified
                y: random(0, scene.height - 500)  // qmllint disable unqualified

                function random(x, y) {
                    const min = Math.ceil(x);
                    const max = Math.floor(y);
                    return Math.floor(Math.random() * (max - min + 1) + min);
                }
            }
        }
    }

    Connections {
        id: nodeClassListConnection
        target: nodeClassList  // qmllint disable unqualified
    }

    Repeater {
        model: nodeClassListConnection.target

        Text {
            required property string nodeName
            x: 30
            y: 40
            text: this.nodeName
        }
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
                console.log("context menu");
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
        sceneScaler.xScale = targetZoom;
        sceneScaler.yScale = targetZoom;
        this.resizeContent(scene.width * scene.currentZoom, scene.height * scene.currentZoom, Qt.point(posX, posY));
        this.returnToBounds();
    }
}
