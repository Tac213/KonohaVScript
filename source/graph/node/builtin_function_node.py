# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from graph import node
from graph.node import base_node


@node.kvs_node
class Print(base_node.BaseNode):

    NODE_NAME = 'print'
    NODE_CATEGORY = 'builtin functions'
