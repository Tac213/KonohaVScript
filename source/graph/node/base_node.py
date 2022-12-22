# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore


class BaseNode(QtCore.QObject):

    NODE_NAME = 'Unknown'
    NODE_CATEGORY = ''
    NODE_CATEGORY_SPLITTER = '|'

    pos_x_changed = QtCore.Signal(name='posXChanged')
    pos_y_changed = QtCore.Signal(name='posYChanged')

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._pos_x = 0.0  # type: float
        self._pos_y = 0.0  # type: float

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
