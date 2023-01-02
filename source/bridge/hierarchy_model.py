# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore, QtQml

from .item import hierarchy_item

# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = 'Python.HierarchyModel'
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QtQml.QmlElement
class HierarchyModel(QtCore.QAbstractItemModel):

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self.items = {}  # type: typing.Dict[str, hierarchy_item.HierarchyItem]
        self.root = hierarchy_item.HierarchyItem()
        self.items[self.root.item_id] = self.root

    def item_index(self, item: hierarchy_item.HierarchyItem) -> QtCore.QModelIndex:
        if not item.parent:
            return QtCore.QModelIndex()
        return self.create_index(item.row(), 0, item)

    def index(self, row: int, column: int, parent: QtCore.QModelIndex = QtCore.QModelIndex()) -> QtCore.QModelIndex:
        """
        override qt virtual function
        """
        parent_item = parent.internal_pointer() if parent.is_valid() else self.root
        if row >= parent_item.children_count() or row < 0:
            return QtCore.QModelIndex()
        return self.create_index(row, column, parent_item.children[row])

    def parent(self, child: QtCore.QModelIndex) -> QtCore.QModelIndex:
        """
        override qt virtual function
        """
        if not child.is_valid():
            return QtCore.QModelIndex()
        item = child.internal_pointer()  #type: hierarchy_item.HierarchyItem
        if item.parent is self.root:
            return QtCore.QModelIndex()
        return self.create_index(item.parent.row(), 0, item.parent)

    def row_count(self, parent: QtCore.QModelIndex = QtCore.QModelIndex()) -> int:
        """
        override qt virtual function
        """
        item = parent.internal_pointer() if parent.is_valid() else self.root
        return item.children_count()

    def column_count(self, parent: QtCore.QModelIndex = QtCore.QModelIndex()) -> int:
        """
        override qt virtual function
        """
        return 1

    def flags(self, index: QtCore.QModelIndex) -> QtCore.Qt.ItemFlag:
        """
        override qt virtual function
        """
        if not index.is_valid():
            return QtCore.Qt.ItemFlag.ItemIsDropEnabled
        return QtCore.Qt.ItemFlag.ItemIsEnabled | QtCore.Qt.ItemFlag.ItemIsSelectable | QtCore.Qt.ItemFlag.ItemIsEditable | QtCore.Qt.ItemFlag.ItemIsDragEnabled  # pylint: disable=line-too-long

    def data(self, index: QtCore.QModelIndex, role: QtCore.Qt.ItemDataRole) -> typing.Any:
        """
        override qt virtual function
        """
        if not index.is_valid():
            return
        item = index.internal_pointer()  # type: hierarchy_item.HierarchyItem
        if role in (QtCore.Qt.ItemDataRole.DisplayRole, QtCore.Qt.ItemDataRole.EditRole):
            return item.var_name

    def set_data(self, index: QtCore.QModelIndex, value: typing.Any, role: QtCore.Qt.ItemDataRole) -> bool:
        """
        override qt virtual function
        """
        if not index.is_valid():
            return False
        item = index.internal_pointer()  # type: hierarchy_item.HierarchyItem
        if role == QtCore.Qt.ItemDataRole.EditRole:
            item.var_name = value
            return True
        return False

    @QtCore.Slot('QVariant')
    def reset(self, serialized_data: typing.Dict[str, typing.Any]) -> None:
        self.begin_reset_model()

        self.items.clear()
        self.root = hierarchy_item.HierarchyItem.deserialize(serialized_data)
        self._set_items(self.root)

        self.end_reset_model()

    def _set_items(self, parent_item: hierarchy_item.HierarchyItem) -> None:
        self.items[parent_item.item_id] = parent_item
        for child in parent_item.children:
            self._set_items(child)
