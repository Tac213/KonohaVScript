# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from graph import node
from graph.node import base_node


@node.kvs_node
class If(base_node.BaseNode):

    NODE_NAME = 'if'
    NODE_CATEGORY = 'code block'
    NODE_DESCRIPTION = 'if {{ condition }}'
    IS_CODE_BLOCK = True
