# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from PyQt6.QtWidgets import QLineEdit
from PyQt6.QtCore import Qt


class HistoryRollbackLineEdit(QLineEdit):
    """
    用于输入python脚本的单行输入框
    """
    STACK_SIZE = 100

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父widget
        """
        super(HistoryRollbackLineEdit, self).__init__(parent)
        self.history = ['']
        self.history_pointer = 0
        self.installEventFilter(self)
        self.returnPressed.connect(self.return_pressed)

    def keyPressEvent(self, event):
        """
        键盘输入事件回调
        Args:
            event: QtGui.QKeyEvent
        Returns:
            None
        """
        if event.key() == Qt.Key.Key_Up:
            if self.history_pointer == 0:
                self.history[0] = self.text()
            self.history_pointer += 1
            self.history_pointer = min(len(self.history) - 1, self.history_pointer)
            self.setText(self.history[self.history_pointer])
        elif event.key() == Qt.Key.Key_Down:
            self.history_pointer -= 1
            self.history_pointer = max(0, self.history_pointer)
            self.setText(self.history[self.history_pointer])
        else:
            return super(HistoryRollbackLineEdit, self).keyPressEvent(event)

    def return_pressed(self):
        """
        增加输入历史
        Returns:
            None
        """
        value = self.text().rstrip()
        if not value:
            return
        if len(self.history) == 1 or len(self.history) > 1 and self.history[1] != value:
            self.history.insert(1, value)
            if len(self.history) > self.STACK_SIZE:
                self.history.pop()
        self.history_pointer = 0
