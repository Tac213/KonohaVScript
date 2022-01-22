# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import os

# 依赖库
_DEPENDENCY = [
    'PyQt6',
]


def check_dependency():
    """
    检查第三方依赖库
    为用户安装第三方依赖库
    Returns:
        None
    """
    for lib_name in _DEPENDENCY:
        try:
            __import__(lib_name)
        except ImportError:
            if os.system('py -3 -m pip install %s' % lib_name):
                from konoha_vscript import logger
                logger.error('py -3 -m pip install %s FAILED!!!', lib_name)
                logger.log_last_except()
                exit(1)
            __import__(lib_name)
