import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls

Item {
    id: port
    Layout.fillWidth: true
    // height: 30
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property string inputType: ''

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 2

        // implemented in rectangle with half-width radius
        Item {
            id: slot
            width: 32
            height: 32
            Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter
            Layout.leftMargin: 5

            Rectangle {
                id: outRing
                anchors.centerIn: parent
                width: slot.width
                height: slot.height
                color: '#909090'
                border.color: '#515151'
                border.width: 4
                radius: this.width / 2
            }

            Rectangle {
                id: innerRing
                anchors.centerIn: parent
                width: slot.width / 2
                height: slot.height / 2
                color: '#41bac899'
                border.color: '#41bac8'
                border.width: 4
                radius: this.width / 2
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
            }
        }
        Loader {
            id: inputLoader

            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter
        }

        Component.onCompleted: {
            var inputType = port.inputType;
            if (inputType === 'textEdit') {
                inputLoader.sourceComponent = textEdit;
            } else if (inputType === 'comboBox') {
                inputLoader.sourceComponent = comboBox;
            }
        }

        // text edit
        Component {
            id: textEdit
            TextField {
                width: 64
                text: 'Hello'
                readOnly: false
            }
        }

        // combobox
        Component {
            id: comboBox
            ComboBox {
                model: ['First', 'Second', 'Third']
            }
        }
    }
}
