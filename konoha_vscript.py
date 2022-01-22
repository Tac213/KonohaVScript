# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import sys
import os
import argparse

import dependency


logger = None
main_window = None


def _init_logger():
    """
    初始化logger
    Returns:
        None
    """
    import const
    import log_manager
    global logger
    log_dir_path = os.path.join(const.ROOT_DIR, const.LOG_DIR_NAME)
    # 创建log目录
    if not os.path.exists(log_dir_path):
        os.mkdir(log_dir_path)
    log_manager.LogManager.tag = const.LOGGER_NAME
    logger = log_manager.LogManager.get_logger(const.LOGGER_NAME, save_file=True, dirname=log_dir_path)
    log_manager.LogManager.set_handler(log_manager.STREAM)


def get_parser():
    """
    初始化argument parser
    Returns:
        argparse.ArgumentParser
    """
    parser = argparse.ArgumentParser()
    return parser


def setup_path():
    """
    初始化sys.path
    Returns:
        None
    """
    script_path = os.path.normpath(os.path.join(os.path.dirname(__file__), 'script'))
    if script_path not in sys.path:
        sys.path.insert(0, script_path)


def main(args):
    """
    主函数，打开应用窗口
    Args:
        args: 解析完成的参数
    Returns:
        None
    """
    from PyQt6.QtWidgets import QApplication
    from PyQt6.QtGui import QIcon
    from PyQt6.QtCore import QDir
    from gui.main_window import MainWindow
    import const

    app = QApplication(sys.argv)

    # 设置应用基础信息
    app_name = const.APP_NAME
    app.setApplicationName(app_name)
    app.setApplicationDisplayName(app_name)
    app.setDesktopFileName(app_name)
    QDir.setSearchPaths(const.RES_DIR, [os.path.normpath(os.path.join(const.ROOT_DIR, const.RES_DIR))])
    app.setWindowIcon(QIcon(const.APP_ICON))

    # 显示主窗口, 如果不用一个变量勾住这个窗口的实例，这个窗口将无法被显示出来，即使在类里面写self.show()也没用
    main_window = MainWindow()
    main_window.on_window_ready()
    main_window.show()

    sys.exit(app.exec())


if __name__ == '__main__':
    dependency.check_dependency()
    setup_path()
    args = get_parser().parse_args(sys.argv[1:])
    main(args)
else:
    # 要在__main__外面初始化logger，否则外部模块拿不到logger
    # 而且__main__的时候也不要初始化logger
    _init_logger()
