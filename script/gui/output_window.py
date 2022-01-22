# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import code

from PyQt6.QtWidgets import QFrame, QToolButton, QToolBar, QVBoxLayout, QWidgetAction, QCheckBox, QMenu
from PyQt6.QtGui import QIcon, QAction, QCursor, QColor
from PyQt6.QtCore import Qt

from gui.find_widget import FindWidget
from gui.output_text_widget import OutputTextWidget, MessageType
from gui.history_rollback_line_edit import HistoryRollbackLineEdit


class OutputWindow(QFrame):
    """
    log输出窗口
    """

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父Widget
        """
        super(OutputWindow, self).__init__(parent)
        self._interpreter = code.InteractiveInterpreter()  # 用来解析脚本
        self._console_handlers = []
        self._setup_ui()

    def _setup_ui(self):
        """
        setup界面
        Returns:
            None
        """
        self._create_actions()
        self._create_tool_bar()
        self.find_widget = FindWidget(self)

        self.prev_button = QToolButton(self)
        self.prev_button.setIcon(QIcon('res:svg/dropup.svg'))
        self.prev_button.setToolTip(self.tr('上一个匹配项'))
        self.prev_button.setFixedSize(16, 16)
        self.prev_button.setAutoRaise(True)
        self.prev_button.clicked.connect(self.find_widget.on_prev)

        self.next_button = QToolButton(self)
        self.next_button.setIcon(QIcon('res:svg/dropdown.svg'))
        self.next_button.setToolTip(self.tr('下一个匹配项'))
        self.next_button.setFixedSize(16, 16)
        self.next_button.setAutoRaise(True)
        self.next_button.clicked.connect(self.find_widget.on_next)

        self.tool_bar.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonIconOnly)
        self.tool_bar.setContentsMargins(0, 0, 0, 0)
        self.tool_bar.addWidget(self.find_widget)
        self.tool_bar.addWidget(self.next_button)
        self.tool_bar.addWidget(self.prev_button)

        self.output_text_widget = OutputTextWidget(self)
        self.output_text_widget.set_find_widget(self.find_widget)
        self.output_text_widget.set_current_message_type(MessageType.NORMAL | MessageType.WARNING | MessageType.ERROR)

        self.console_input = HistoryRollbackLineEdit(self)
        self.console_input.setPlaceholderText('input python code to debug...')
        self.console_input.returnPressed.connect(self._on_console_send)

        layout = QVBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        layout.addWidget(self.tool_bar)
        layout.addWidget(self.output_text_widget)
        layout.addWidget(self.console_input)
        self.setLayout(layout)

        self._create_message_actions()

    def _create_actions(self):
        """
        创建相关QActions
        Returns:
            None
        """
        self.clear_action = QAction(QIcon('res:svg/clear.svg'), self.tr('清除'), self)
        self.clear_action.setToolTip(self.tr('清空输出窗口信息'))
        self.clear_action.triggered.connect(self._on_clear)

        self.show_menu_action = QAction(QIcon('res:svg/menu.svg'), self.tr('输出类型菜单'), self)
        self.show_menu_action.setToolTip(self.tr('显示输出类型菜单'))
        self.show_menu_action.triggered.connect(self._on_show_message_menu)

        self.search_action = QAction(QIcon('res:svg/search.svg'), self.tr('搜索'), self)
        self.search_action.setToolTip(self.tr('在输出窗口中搜索'))
        self.search_action.triggered.connect(self._on_search)

    def _create_tool_bar(self):
        """
        创建工具栏
        Returns:
            None
        """
        self.tool_bar = QToolBar(self)
        self.tool_bar.addSeparator()
        self.tool_bar.addAction(self.show_menu_action)
        self.tool_bar.addAction(self.clear_action)

    def _create_message_actions(self):
        """
        创建message filter的相关action
        Returns:
            None
        """
        self._actions = {}
        for msg_type in (MessageType.NORMAL, MessageType.WARNING, MessageType.ERROR):
            action = QWidgetAction(self)
            check_box = QCheckBox(MessageType.MESSAGE_TYPE_NAME[msg_type], self)
            action.setDefaultWidget(check_box)
            check_box.stateChanged.connect(self._on_message_type_filter_changed)
            check_box.setCheckable(True)
            self._actions[msg_type] = action
        for action in self._actions.values():
            action.defaultWidget().setChecked(True)

    def _on_show_message_menu(self):
        """
        显示message菜单Action回调
        Returns:
            None
        """
        menu = QMenu()
        for msg_type in (MessageType.NORMAL, MessageType.WARNING, MessageType.ERROR):
            menu.addAction(self._actions[msg_type])
        if menu:
            menu.exec(QCursor.pos())

    def _on_clear(self):
        """
        清除输出窗口信息Action回调
        Returns:
            None
        """
        self.output_text_widget.clear_text()

    def _on_search(self):
        """
        搜索Action回调
        Returns:
            None
        """
        self.output_text_widget.on_find()

    def _on_message_type_filter_changed(self):
        """
        消息类型过滤器变化回调
        Returns:
            None
        """
        msg_types = 0
        for m_type, action in self._actions.items():
            if action.defaultWidget().isChecked():
                msg_types |= m_type
        self.output_text_widget.set_current_message_type(msg_types)

    def _on_console_send(self):
        """
        输入python脚本回调
        Returns:
            None
        """
        script = self.console_input.text().strip()
        self.show_normal_message('>>> %s' % script)
        if script:
            for handler in self._console_handlers:
                if handler(script):
                    break
            else:
                self._interpreter.runsource(script)
        self.console_input.setText('')

    def clear_output(self):
        """
        清理所有的输出文本
        Returns:
            None
        """
        self._on_clear()

    def add_console_handler(self, handler):
        """
        增加console的handler
        Args:
            handler: callabel
        Returns:
            None
        """
        if handler not in self._console_handlers:
            self._console_handlers.append(handler)

    def show_message(self, text, msg_type=MessageType.NORMAL):
        """
        显示信息
        Args:
            text: [str]原始文本
            msg_type: MessageType
        Returns:
            None
        """
        if msg_type == MessageType.WARNING:
            color = QColor(237, 125, 49, 255)
        elif msg_type == MessageType.ERROR:
            color = QColor(255, 0, 0, 255)
        else:
            color = QColor(0, 0, 0, 255)
        self.output_text_widget.add_item(text, msg_type, color)

    def show_html_message(self, html_msg, msg_type=MessageType.NORMAL):
        """
        显示html信息
        Args:
            html_msg: [str]html文本
            msg_type: MessageType
        Returns:
            None
        """
        self.output_text_widget.add_html(html_msg, msg_type)

    def show_normal_message(self, msg):
        """
        显示普通信息
        Args:
            msg: [str]信息文本
        Returns:
            None
        """
        self.show_message(msg, MessageType.NORMAL)

    def show_warning_message(self, msg):
        """
        显示警告信息
        Args:
            msg: [str]信息文本
        Returns:
            None
        """
        self.show_message(msg, MessageType.WARNING)

    def show_error_message(self, msg):
        """
        显示错误信息
        Args:
            msg: [str]信息文本
        Returns:
            None
        """
        self.show_message(msg, MessageType.ERROR)
