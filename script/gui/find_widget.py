# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from PyQt6.QtWidgets import QFrame, QHBoxLayout, QToolButton
from PyQt6.QtGui import QIcon
from PyQt6.QtCore import pyqtSignal, Qt

from gui.search_line_edit import SearchLineEdit


class FindWidget(QFrame):
    """
    查找log的widget
    """

    next_clicked = pyqtSignal()
    prev_clicked = pyqtSignal()
    close_clicked = pyqtSignal()
    text_changed = pyqtSignal(str)

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父widget
        """
        super(FindWidget, self).__init__(parent)
        layout = QHBoxLayout()
        self.line_edit = SearchLineEdit(self)
        self.line_edit.textChanged.connect(self._on_text_changed)
        self.line_edit.returnPressed.connect(self.on_next)
        layout.addWidget(self.line_edit)

        self.close_button = QToolButton(self)
        self.close_button.setIcon(QIcon('res:svg/titlebar_closewindow.svg'))
        self.close_button.setFixedSize(7, 7)
        self.close_button.setAutoRaise(True)
        self.close_button.clicked.connect(self._on_close)
        layout.addWidget(self.close_button)

        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        self.setLayout(layout)

        self.line_edit.setFocus(Qt.FocusReason.OtherFocusReason)

    def _on_text_changed(self, text):
        """
        搜索输入栏输入变化回调
        Args:
            text: [str]当前输入的内容
        Returns:
            None
        """
        self.text_changed.emit(text)

    def _on_close(self):
        """
        关闭查找界面回调
        Returns:
            None
        """
        self.hide()
        self.close_clicked.emit()

    def on_next(self):
        """
        下一个结果的回调
        Returns:
            None
        """
        self.next_clicked.emit()

    def on_prev(self):
        """
        上一个查找结果的回调
        Returns:
            None
        """
        self.prev_clicked.emit()

    def get_text(self):
        """
        获取当前输入的内容
        Returns:
            str
        """
        return self.line_edit.text()

    def keyPressEvent(self, event):
        """
        键盘输入事件回调
        Args:
            event: QtGui.QKeyEvent
        Returns:
            None
        """
        if event.key() == Qt.Key.Key_Escape:
            self._on_close()
        else:
            return super(FindWidget, self).keyPressEvent(event)
