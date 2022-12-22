# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

import shortuuid
from PySide6 import QtCore

from utils import advanced_qt_property
from .node import base_node


class BaseGraph(QtCore.QObject, metaclass=advanced_qt_property.QObjectMeta):  # pylint: disable=invalid-metaclass

    nodes = advanced_qt_property.AdvancedQtProperty('QVariant')  # type: typing.Dict[str, base_node.BaseNode]

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._nodes = {}

    @QtCore.Slot(str, result=bool)
    def check_node_id(self, node_id) -> bool:
        return bool(node_id and node_id not in self._nodes)

    @QtCore.Slot(result=str)
    def generate_node_id(self) -> str:
        return shortuuid.uuid()

    @QtCore.Slot(str, base_node.BaseNode)
    def add_node(self, node_id, node_model):
        self._nodes[node_id] = node_model
