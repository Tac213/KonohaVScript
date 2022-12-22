# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

import shortuuid
from PySide6 import QtCore

from . import node
from .node import base_node


class BaseGraph(QtCore.QObject):

    nodes_changed = QtCore.Signal(name='nodesChanged')

    def __init__(self, parent: typing.Optional[QtCore.QObject] = None) -> None:
        super().__init__(parent)
        self._nodes = {}

    def get_nodes(self) -> typing.Dict[str, base_node.BaseNode]:
        return self._nodes

    def set_nodes(self, nodes: typing.Dict[str, base_node.BaseNode]) -> None:
        self._nodes = nodes

    nodes = QtCore.Property('QVariant', get_nodes, set_nodes, notify=nodes_changed)

    @QtCore.Slot(str, float, float, str, result=base_node.BaseNode)
    def create_node(self, node_class_name: str, pos_x: float, pos_y: float, node_id: str = None) -> typing.Optional[base_node.BaseNode]:
        if not node_id:
            node_id = shortuuid.uuid()
        node_class = node.get_node_class(node_class_name)
        if not node_class:
            return None
        node_model = node_class()
        node_model.pos_x = pos_x
        node_model.pos_y = pos_y
        return node_model
