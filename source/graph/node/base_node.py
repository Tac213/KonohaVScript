# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore

from utils import advanced_qt_property


class BaseNode(QtCore.QObject, metaclass=advanced_qt_property.QObjectMeta):  # pylint: disable=invalid-metaclass

    NODE_NAME = 'Unknown'
    NODE_CATEGORY = ''
    NODE_CATEGORY_SPLITTER = '|'

    node_class_name = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    node_id = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    pos_x = advanced_qt_property.AdvancedQtProperty(float)  # type: float
    pos_y = advanced_qt_property.AdvancedQtProperty(float)  # type: float

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._node_class_name = self.__class__.__name__
        self._node_id = ''
        self._pos_x = 0.0
        self._pos_y = 0.0
