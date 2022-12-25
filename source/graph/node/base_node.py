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
    NODE_DESCRIPTION = ''
    NODE_BLOCK_DESCRIPTIONS = []
    IS_STATEMENT = True
    IS_CODE_BLOCK = False

    input_args = advanced_qt_property.AdvancedQtProperty('QVariant')  # type: typing.Dict[str, str]
    next_node_id = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    node_class_name = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    node_id = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    pos_x = advanced_qt_property.AdvancedQtProperty(float)  # type: float
    pos_y = advanced_qt_property.AdvancedQtProperty(float)  # type: float
    node_description = advanced_qt_property.AdvancedQtProperty(str)  # type: str
    node_block_descriptions = advanced_qt_property.AdvancedQtProperty(list)  # type: list
    is_statement = advanced_qt_property.AdvancedQtProperty(bool)  # type: bool
    is_code_block = advanced_qt_property.AdvancedQtProperty(bool)  # type: bool

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._input_args = {}
        self._next_node_id = ''
        self._node_class_name = self.__class__.__name__
        self._node_id = ''
        self._pos_x = 0.0
        self._pos_y = 0.0
        self._node_description = self.NODE_DESCRIPTION
        self._node_block_descriptions = self.NODE_BLOCK_DESCRIPTIONS
        self._is_statement = self.IS_STATEMENT
        self._is_code_block = self.IS_CODE_BLOCK

    @QtCore.Slot(str, str)
    def add_input_argument(self, arg_name, arg_node_id) -> None:
        self._input_args[arg_name] = arg_node_id

    @QtCore.Slot(str)
    def remove_input_argument(self, arg_name) -> None:
        if arg_name in self._input_args:
            self._input_args.pop(arg_name)
