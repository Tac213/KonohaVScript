import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "NodeGraphComponents" as NodeGraphComponents

ApplicationWindow {
    id: root

    title: qsTr("KonohaVScript")
    width: 1334
    height: 750
    visible: true

    menuBar: MenuBar {
        id: menuBar
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Exit")
                onTriggered: () => {
                    Qt.quit();
                }
            }
        }
        Menu {
            title: qsTr("&Developer")
            MenuItem {
                text: qsTr("&Toggle Console")
                onTriggered: () => {
                    toggleConsoleWindow();
                }
            }
        }
    }
    RowLayout {
        anchors.fill: parent
        NodeGraphComponents.NodeGraphView {
            id: nodeGraphView
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Item {
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_QuoteLeft) {
                toggleConsoleWindow();
            }
        }
    }

    OutputWindow {
        id: consoleWindow
    }

    function toggleConsoleWindow() {
        consoleWindow.visible = !consoleWindow.visible;
    }
}
