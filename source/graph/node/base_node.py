# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore


class BaseNode(QtCore.QObject):

    NODE_NAME = 'Unknown'
    NODE_CATEGORY = ''
    NODE_CATEGORY_SPLITTER = '|'

    node_class_name_changed = QtCore.Signal(name='nodeClassNameChanged')
    node_id_changed = QtCore.Signal(name='nodeIDChanged')
    pos_x_changed = QtCore.Signal(name='posXChanged')
    pos_y_changed = QtCore.Signal(name='posYChanged')

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._node_class_name = self.__class__.__name__  # type: str
        self._node_id = ''  # type: str
        self._pos_x = 0.0  # type: float
        self._pos_y = 0.0  # type: float

    def get_node_class_name(self) -> str:
        return self._node_class_name

    def set_node_class_name(self, node_class_name: str) -> None:
        self._node_class_name = node_class_name

    node_class_name = QtCore.Property(str, get_node_class_name, set_node_class_name, notify=node_class_name_changed)

    def get_node_id(self) -> str:
        return self._node_id

    def set_node_id(self, node_id: str) -> None:
        self._node_id = node_id

    node_id = QtCore.Property(str, get_node_id, set_node_id, notify=node_id_changed)

    def get_pos_x(self) -> float:
        return self._pos_x

    def set_pos_x(self, pos_x: float) -> None:
        self._pos_x = pos_x

    def get_pos_y(self) -> float:
        return self._pos_y

    def set_pos_y(self, pos_y: float) -> None:
        self._pos_y = pos_y

    pos_x = QtCore.Property(float, get_pos_x, set_pos_x, notify=pos_x_changed)
    pos_y = QtCore.Property(float, get_pos_y, set_pos_y, notify=pos_y_changed)
