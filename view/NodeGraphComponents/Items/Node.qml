import QtQuick
import QtQuick.Layouts
import "." as NodeGraphItems

Item {
    width: 300

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: header
            Layout.fillWidth: true
            height: 40
            property int borderRadius: 5

            // header background
            Rectangle {
                anchors.fill: parent
                color: '#777777'
                radius: header.borderRadius
            }
            Rectangle {
                x: 0
                y: header.borderRadius
                width: header.width
                height: header.height - header.borderRadius
                color: '#777777'
            }

            // header
            RowLayout {
                id: headerLayout
                anchors.fill: parent

                Image {
                    source: 'qrc:/resource/svg/PlayerAvatar.svg'
                    sourceSize.width: 24
                    sourceSize.height: 24
                    Layout.leftMargin: 5
                    horizontalAlignment: Qt.AlignHCenter
                }

                Text {
                    text: 'Texture Sample'
                    font.pixelSize: 24
                    color: 'white'
                    Layout.leftMargin: 5
                    horizontalAlignment: Qt.AlignHCenter
                }

                Image {
                    source: 'qrc:/resource/svg/Show1.svg'
                    sourceSize.width: 24
                    sourceSize.height: 24
                    Layout.rightMargin: 5
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }

        Item {
            id: body
            Layout.fillWidth: true
            implicitWidth: panel.implicitWidth
            implicitHeight: panel.implicitHeight

            Rectangle {
                anchors.fill: parent
                color: '#999999'
            }

            RowLayout {
                id: panel
                anchors.fill: parent

                // input port list and preview
                ColumnLayout {
                    Layout.topMargin: 5

                    // Layout.maximumWidth: 200
                    NodeGraphItems.Port {
                        inputType: 'textEdit'
                    }
                    NodeGraphItems.Port {
                        inputType: 'comboBox'
                    }
                    NodeGraphItems.Port {
                        inputType: 'comboBox'
                    }
                    Image {
                        source: 'qrc:/resource/icon.jpg'
                        sourceSize.width: 200
                        sourceSize.height: 200
                    }
                }

                // output port list
                ColumnLayout {
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight

                    NodeGraphItems.Port {
                    }
                    NodeGraphItems.Port {
                    }
                    NodeGraphItems.Port {
                    }
                }
            }
        }
    }
}
