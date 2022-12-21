# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore
from __feature__ import snake_case, true_property  # pylint: disable=import-error,unused-import


class NodeClassListModel(QtCore.QAbstractListModel):

    node_name_role = QtCore.Qt.ItemDataRole.UserRole + 1

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self.node_classes = []

    def row_count(self, parent: typing.Union[QtCore.QModelIndex, QtCore.QPersistentModelIndex]) -> int:
        return len(self.node_classes)

    def data(self, index: typing.Union[QtCore.QModelIndex, QtCore.QPersistentModelIndex], role: QtCore.Qt.ItemDataRole) -> typing.Any:
        if not index.is_valid():
            return
        row_index = index.row()
        if row_index < 0 or row_index >= len(self.node_classes):
            return
        node_class = self.node_classes[row_index]
        if role == self.node_name_role:
            return node_class.NODE_NAME

    def role_names(self) -> typing.Dict[QtCore.Qt.ItemDataRole, QtCore.QByteArray]:
        return {
            self.node_name_role: QtCore.QByteArray(b'nodeName'),
        }

    def add_node_class(self, node_class) -> None:
        parent_index = QtCore.QModelIndex()
        self.begin_insert_rows(parent_index, len(self.node_classes), len(self.node_classes))
        self.node_classes.append(node_class)
        self.end_insert_rows()
