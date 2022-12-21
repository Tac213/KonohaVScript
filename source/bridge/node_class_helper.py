# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from PySide6 import QtCore, QtQml

from graph import node

# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = 'Python.NodeClassHelper'
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QtQml.QmlElement
class NodeClassHelper(QtCore.QObject):

    @QtCore.Slot(result='QVariant')
    def get_node_category_info(self) -> dict:
        result = {}
        for node_class_name, node_class in node.node_class_info.items():
            node_categories = node_class.NODE_CATEGORY.split(node_class.NODE_CATEGORY_SPLITTER)
            category_info = result
            for category in node_categories:
                category_info = category_info.setdefault(category, {})  # type: dict
            category_info[node_class_name] = True
        return result

    @QtCore.Slot(result=list)
    def get_all_node_class_names(self) -> list:
        return list(node.node_class_info.keys())

    @QtCore.Slot(str, result=str)
    def get_node_class_show_name(self, node_class_name) -> str:
        node_class = node.node_class_info.get(node_class_name)
        if not node_class:
            return 'Unknown Node'
        return node_class.NODE_NAME
