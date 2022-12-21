# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import importlib

from PySide6 import QtQml

ALL_BRIDGE_MODULES = (
    'interactive_interpreter',
    'output_window_bridge',
    'syntax_highlighter',
)

output_window_bridge_object = None
node_class_list = None


def register_bridges() -> None:
    """
    register all bridges
    Returns:
        None
    """
    for module_name in ALL_BRIDGE_MODULES:
        importlib.import_module(f'.{module_name}', __name__)


def initialize_bridge_objects() -> None:
    from . import output_window_bridge  # pylint: disable=import-outside-toplevel
    global output_window_bridge_object
    output_window_bridge_object = output_window_bridge.OutputWindowBridge()
    initialize_node_class_list()


def initialize_node_class_list() -> None:
    from . import node_class_list_model  # pylint: disable=import-outside-toplevel
    from graph import node  # pylint: disable=import-outside-toplevel
    global node_class_list
    node_class_list = node_class_list_model.NodeClassListModel()
    node.register_nodes()


def get_bridge_objects():
    result = []
    if output_window_bridge_object:
        property_pair = QtQml.QQmlContext.PropertyPair()
        property_pair.name = 'outputWindowBridge'
        property_pair.value = output_window_bridge_object
        result.append(property_pair)
    if node_class_list:
        property_pair = QtQml.QQmlContext.PropertyPair()
        property_pair.name = 'nodeClassList'
        property_pair.value = node_class_list
        result.append(property_pair)
    return result


def finalize_bridge_objects() -> None:
    if output_window_bridge_object:
        output_window_bridge_object.delete_later()
