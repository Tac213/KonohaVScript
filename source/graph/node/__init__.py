# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing
import importlib
from PySide6 import QtQml
from . import base_node

ALL_NODE_MODULES = (
    'builtin_function_node',
    'code_block_node',
    'literal_node',
)

node_class_info = {}  # type: typing.Dict[str, type[base_node.BaseNode]]
node_class_list = []  # type: typing.List[type[base_node.BaseNode]]


def kvs_node(node_class: type[base_node.BaseNode]) -> type[base_node.BaseNode]:
    """
    decorate a node class to register node
    """
    assert issubclass(node_class, base_node.BaseNode)
    assert node_class.__name__ not in node_class_info
    node_class_info[node_class.__name__] = node_class
    node_class_list.append(node_class)
    QtQml.qmlRegisterType(node_class, 'Python.NodeModels', 1, 0, node_class.__name__)
    return node_class


def register_nodes() -> None:
    """
    register all nodes
    Returns:
        None
    """
    for module_name in ALL_NODE_MODULES:
        importlib.import_module(f'.{module_name}', __name__)


def get_node_class(node_class_name: str) -> typing.Optional[type[base_node.BaseNode]]:
    return node_class_info.get(node_class_name)
