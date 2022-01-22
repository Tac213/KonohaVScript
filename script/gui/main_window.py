# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from PyQt6.QtWidgets import QMainWindow, QHBoxLayout, QWidget, QDockWidget
from PyQt6.QtCore import Qt

from gui.output_window import OutputWindow

main_window = None  # MainWindow的实例


class MainWindow(QMainWindow):
    """
    gui界面的主窗口
    """

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父Widget
        """
        super(MainWindow, self).__init__(parent)
        self.console = QDockWidget('Console', self)
        self.console_window = OutputWindow(self.console)

        self._setup_ui()
        global main_window
        main_window = self

    def _setup_ui(self):
        """
        setup界面
        Returns:
            None
        """
        self.resize(960, 480)
        central_widget = QWidget(self)
        layout = QHBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        central_widget.setLayout(layout)
        self.layout = layout
        self.setCentralWidget(central_widget)
        self.console.setWidget(self.console_window)
        self.console.setObjectName('console')
        self.console.setAllowedAreas(Qt.DockWidgetArea.NoDockWidgetArea)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, self.console)
        self.console.setFloating(True)
        self.console.resize(800, 400)
        self.console.setVisible(False)  # 默认隐藏console

    def on_window_ready(self):
        """
        main window准备完成回调
        Returns:
            None
        """
        from log_manager import OutputWindowHandler
        OutputWindowHandler.main_window_ready = True

    def toggle_console(self):
        """
        toggle console界面
        Returns:
            None
        """
        self.console.setVisible(not self.console.isVisible())

    def keyPressEvent(self, event):
        """
        监听按键事件
        Args:
            event: QtGui.QKeyEvent
        Returns:
            None
        """
        if event.key() == Qt.Key.Key_QuoteLeft:
            self.toggle_console()
        super(MainWindow, self).keyPressEvent(event)

    def create_python_output_window(self):
        """
        创建显示python日志的窗口
        Returns:
            OutputWindow的实例
        """
        self.output_window = OutputWindow(self)
        self.layout.addWidget(self.output_window)
        return self.output_window
