# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from graph import node
from graph.node import base_node


@node.kvs_node
class StringLiteral(base_node.BaseNode):

    NODE_NAME = 'string literal'
    NODE_CATEGORY = 'literals'
    NODE_DESCRIPTION = '{{ __raw_input__ }}'
    IS_STATEMENT = False
