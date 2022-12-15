import QtQuick
import "Items" as NodeGraphItems

Flickable {
    id: root
    clip: true
    contentWidth: viewport.width
    contentHeight: viewport.height
    Item {
        id: viewport
        width: 12000
        height: 12000

        MouseArea {
            anchors.fill: parent
            onWheel: () => {
                console.log('wheeled');
                // line.endY += 10;
            }
            onClicked: () => {
                console.log('clicked');
            }
        }

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
                x: random(0, viewport.width - 300)  // qmllint disable unqualified
                y: random(0, viewport.height - 500)  // qmllint disable unqualified

                function random(x, y) {
                    const min = Math.ceil(x);
                    const max = Math.floor(y);
                    return Math.floor(Math.random() * (max - min + 1) + min);
                }
            }
        }
        NodeGraphItems.Line {
            id: line
            startX: 30
            startY: 30
            endX: 100
            endY: 100
        }
    }
}
