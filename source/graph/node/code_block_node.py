# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from graph import node
from graph.node import base_node


@node.kvs_node
class If(base_node.BaseNode):

    NODE_NAME = 'if'
    NODE_CATEGORY = 'code block'
    NODE_BRANCH_DESCRIPTIONS = ['if {{ condition }}']
    IS_CODE_BLOCK = True


@node.kvs_node
class For(base_node.BaseNode):

    NODE_NAME = 'for'
    NODE_CATEGORY = 'code block'
    NODE_BRANCH_DESCRIPTIONS = ['for {{ var_name }} in {{ iterable }}']
    IS_CODE_BLOCK = True


@node.kvs_node
class While(base_node.BaseNode):

    NODE_NAME = 'while'
    NODE_CATEGORY = 'code block'
    NODE_BRANCH_DESCRIPTIONS = ['while {{ condition }}']
    IS_CODE_BLOCK = True
