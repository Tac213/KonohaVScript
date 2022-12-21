# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import importlib
import bridge

ALL_NODE_MODULES = (
    'builtin_function_node',
    'literal_node',
)


def kvs_node(node_class):
    """
    decorate a node class to register node
    """
    if bridge.node_class_list:
        bridge.node_class_list.add_node_class(node_class)
    return node_class


def register_nodes() -> None:
    """
    register all nodes
    Returns:
        None
    """
    for module_name in ALL_NODE_MODULES:
        importlib.import_module(f'.{module_name}', __name__)
