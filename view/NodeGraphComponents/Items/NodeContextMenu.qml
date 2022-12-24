import QtQuick
import QtQuick.Controls

Menu {
    id: root
    required property var node

    Action {
        id: unsnapArgument
        text: qsTr('Unsnap this argument')
        enabled: !root.node.model.is_statement && root.node.snapped
        onTriggered: () => {
            root.node.getHandler().unsnapArgument(root.node);
        }
    }
}
