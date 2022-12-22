# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing
import importlib
from PySide6 import QtQml
from . import base_graph

ALL_GRAPH_MODULES = (
    'script_graph',
    'function_graph',
)

graph_class_info = {}  # typing.Dict[str, type[base_graph.BaseGraph]]


def kvs_graph(graph_class: type[base_graph.BaseGraph]) -> type[base_graph.BaseGraph]:
    """
    decorate a graph class to register node
    """
    assert issubclass(graph_class, base_graph.BaseGraph)
    assert graph_class.__name__ not in graph_class_info
    graph_class_info[graph_class.__name__] = graph_class
    QtQml.qmlRegisterType(graph_class, 'Python.GraphModels', 1, 0, graph_class.__name__)
    return graph_class


def register_graphs() -> None:
    """
    register all graphs
    Returns:
        None
    """
    for module_name in ALL_GRAPH_MODULES:
        importlib.import_module(f'.{module_name}', __name__)


def get_graph_class(graph_class_name: str) -> typing.Optional[type[base_graph.BaseGraph]]:
    return graph_class_info.get(graph_class_name)
