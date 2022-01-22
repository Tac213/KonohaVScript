# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

from PyQt6.QtWidgets import QLineEdit, QToolButton, QStyleOptionFrame, QStyle
from PyQt6.QtGui import QIcon
from PyQt6.QtCore import Qt, QRect


class SearchLineEdit(QLineEdit):
    """
    搜索框的line edit widget
    """

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父widget
        """
        super(SearchLineEdit, self).__init__(parent)
        self.search_button = QToolButton(self)
        self.search_button.setIcon(QIcon('res:svg/search.svg'))
        self.search_button.setCursor(Qt.CursorShape.ArrowCursor)
        self.search_button.setPopupMode(QToolButton.ToolButtonPopupMode.InstantPopup)
        self.search_button.setAutoRaise(True)

        self.clear_button = QToolButton(self)
        self.clear_button.setIcon(QIcon('res:svg/clear.svg'))
        self.clear_button.setCursor(Qt.CursorShape.ArrowCursor)
        self.clear_button.setPopupMode(QToolButton.ToolButtonPopupMode.InstantPopup)
        self.clear_button.setAutoRaise(True)

        self.update_geometry()

        self.setPlaceholderText('search...')

        self.clear_button.hide()
        self.clear_button.clicked.connect(self.clear)
        self.textChanged.connect(self.update_clear_button)

    def update_geometry(self):
        """
        更新geometry
        Returns:
            None
        """
        option = QStyleOptionFrame()
        self.initStyleOption(option)
        rect = self.style().subElementRect(QStyle.SubElement.SE_LineEditContents, option, self)
        font_metrics = self.fontMetrics()
        horizontal_margin = 2

        real_rect = QRect(
            rect.x() + horizontal_margin,
            rect.y() + (rect.height() - font_metrics.height() + 1) / 2,
            rect.width() - 2 * horizontal_margin,
            font_metrics.height()
        )

        icon_margin = 1
        icon_height = real_rect.height() - 2 * icon_margin

        self.search_button.setFixedSize(real_rect.height() - 2 * icon_margin, real_rect.height() - 2 * icon_margin)
        self.search_button.setGeometry(
            real_rect.x() - real_rect.height() - icon_margin,
            real_rect.y() + icon_margin,
            icon_height,
            icon_height,
        )

        self.clear_button.setFixedSize(real_rect.height() - 2 * icon_margin, real_rect.height() - 2 * icon_margin)
        self.clear_button.setGeometry(
            real_rect.right() + icon_margin,
            real_rect.y() + icon_margin,
            icon_height,
            icon_height,
        )

    def update_clear_button(self, text):
        """
        更新清除按钮状态
        Args:
            text: [str]当前输入的文本
        Returns:
            None
        """
        if text:
            self.clear_button.show()
            self.update_geometry()
        else:
            self.clear_button.hide()

    def resizeEvent(self, _):
        """
        改变尺寸事件回调
        Args:
            _: QtGui.QResizeEvent
        Returns:
            None
        """
        self.update_geometry()
