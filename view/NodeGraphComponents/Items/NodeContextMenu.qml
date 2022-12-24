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

    Action {
        id: unsnapPrevious
        text: qsTr('Unsnap previous statement')
        enabled: root.node.model.is_statement && root.node.snapped
        onTriggered: () => {
            root.node.getHandler().unsnapStatement(root.node);
        }
    }

    Action {
        id: unsnapNext
        text: qsTr('Unsnap next statement')
        enabled: root.node.model.is_statement && root.node.nextNodeID !== ''
        onTriggered: () => {
            root.node.getHandler().unsnapNextStatement(root.node);
        }
    }
}
