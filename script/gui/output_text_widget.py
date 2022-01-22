# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import os
import re
import html
import urllib.parse

from PyQt6.QtWidgets import QTextBrowser, QMessageBox
from PyQt6.QtGui import QTextCursor, QBrush, QColor, QTextDocument
from PyQt6.QtCore import QTimer, Qt


class MessageType(object):
    NORMAL = 0b1
    WARNING = 0b10
    ERROR = 0b100

    MESSAGE_TYPE_NAME = {
        NORMAL: 'Normal',
        WARNING: 'Warning',
        ERROR: 'Error',
    }


class OutputTextWidget(QTextBrowser):
    """
    用来显示log输出的文字
    """
    MAX_LINES = 1000  # 最多显示的行数
    MAX_LINE_LENGTH = 300  # 一行最多显示多少个字

    def __init__(self, parent=None):
        """
        构造器
        Args:
            parent: 父widget
        """
        super(OutputTextWidget, self).__init__(parent)
        self.setOpenExternalLinks(False)

        self.trace_reg = re.compile(r'(File &quot;(.+?)&quot;, line (\d{1,5}), in (.+?))')

        self.anchorClicked.connect(self.anchor_clicked)

        self.find_widget = None
        self.search_text = None  # 查找到的文本
        self.insert_counter = 0
        self.output_texts = []  # 记录所有的输出文本及其类型
        self.curr_message_type = MessageType.NORMAL | MessageType.WARNING | MessageType.ERROR  # 当前的消息类型

        self._scroll_timer = QTimer(self)
        self._scroll_timer.timeout.connect(self.scroll_to_bottom)

    def scroll_to_bottom(self):
        """
        滚动到底部
        Returns:
            None
        """
        bar = self.verticalScrollBar()
        bar.setValue(bar.maximum())
        if self._scroll_timer.isActive():
            self._scroll_timer.stop()

    def _delay_scroll_to_bottom(self, delay=200):
        """
        延迟200毫秒滚动到底部
        Args:
            delay: [int]延迟时间
        Returns:
            None
        """
        if self._scroll_timer.isActive():
            self._scroll_timer.stop()
        self._scroll_timer.start(delay)

    def resizeEvent(self, event):
        """
        改变尺寸事件回调
        Args:
            event: QResizeEvent
        Returns:
            None
        """
        bar = self.verticalScrollBar()
        is_at_bottom = bar.value() >= bar.maximum()
        super(OutputTextWidget, self).resizeEvent(event)
        if is_at_bottom:
            self._delay_scroll_to_bottom()

    def changeEvent(self, event):
        """
        改变事件回调
        Args:
            event: QEvent
        Returns:
            None
        """
        bar = self.verticalScrollBar()
        is_at_bottom = bar.value() >= bar.maximum()
        super(OutputTextWidget, self).changeEvent(event)
        if is_at_bottom:
            self._delay_scroll_to_bottom()

    def keyPressEvent(self, event):
        """
        键盘事件
        Args:
            event: QKeyEvent
        Returns:
            None
        """
        if event.key() == Qt.Key.Key_Find:
            self.on_find()
        else:
            super(OutputTextWidget, self).keyPressEvent(event)

    def clear_text(self):
        """
        清除文本
        Returns:
            None
        """
        self.clear()
        self.output_texts.clear()

    def set_current_message_type(self, msg_type):
        """
        设置当前的消息类型
        Args:
            msg_type: MessageType
        Returns:
            None
        """
        if self.curr_message_type == msg_type:
            return
        self.clear()
        for m_type, text in self.output_texts:
            if m_type & msg_type:
                self.append(text)
        self.curr_message_type = msg_type

    def add_item(self, item, msg_type=MessageType.NORMAL, color=None):
        """
        增加一个文本item
        Args:
            item: [str]文本内容
            msg_type: MessageType
            color: QColor
        Returns:
            None
        """
        self.insert_counter += 1
        if self.insert_counter % (self.MAX_LINES / 10) == 0:
            # 每加100个检查一次是否超过上限需要截断
            self._truncate_if_exceed()

        color_name = color.name() if color else 'grey'
        if len(item) > self.MAX_LINE_LENGTH:
            text, left_text = item[:self.MAX_LINE_LENGTH], item[self.MAX_LINE_LENGTH:]
            text = html.escape(text)
            text += '<a href="#wrap:%s" style="color:%s">......</a>' % (urllib.parse.quote(left_text), color_name)
        else:
            text = html.escape(item)

        left_text = self._process_text(text)
        if color:
            text = '<span style=\'color:%s;white-space:pre;\'>%s</span>' % (color_name, left_text)
        else:
            text = '<span style=\'white-space:pre;\'>%s</span>' % left_text
        self._add_text(text, msg_type)

    def add_html(self, html_text, msg_type=MessageType.NORMAL):
        """
        增加html文本
        Args:
            html_text: [str]html文本
            msg_type: MessageType
        Returns:
            None
        """
        self._add_text(html_text, msg_type)

    def anchor_clicked(self, link):
        """
        点击href标签回调
        Args:
            link: QUrl
        Returns:
            None
        """
        url = urllib.parse.unquote(link.toString()).replace('<br/>', '\n')
        if url.startswith('#wrap:'):
            left_text = url[len('#wrap:'):]
            block = self.textCursor().block()
            cursor = QTextCursor(block)
            cursor.movePosition(QTextCursor.MoveOperation.EndOfBlock)
            # 删除省略号
            for _ in '......':
                cursor.deletePreviousChar()
            char_format = cursor.charFormat()
            block_text = '%s%s' % (block.text(), left_text)
            color_name = char_format.foreground().color().name()
            ret = '<span style=\'color:%s;white-space:pre;\'>%s</span>'\
                  % (color_name, self._process_text(html.escape(block_text)))
            cursor.movePosition(QTextCursor.MoveOperation.StartOfBlock, QTextCursor.MoveMode.KeepAnchor)
            cursor.removeSelectedText()
            cursor.insertHtml(ret)
        else:
            url = url[1:]
            idx = url.rfind('.')
            if idx == -1 or idx >= len(url):
                return
            filename, _ = url[:idx], int(url[(idx + 1):]) - 1
            if not os.path.isfile(filename):
                return QMessageBox.information(self, 'Error', self.tr('无法找到文件: %s') % filename)

    def _process_text(self, text, color='#1a77e6'):
        """
        处理文本
        自动添加链接、html转义、换行转换
        Args:
            text: [str]文本
            color: [str]颜色值
        Returns:
            str
        """
        def _replace_trace_file(match_obj):
            """
            替换trace的文件
            Args:
                match_obj:
            Returns:
                str
            """
            line, filename, line_no, _ = match_obj.groups()
            link = urllib.parse.quote('%s.%d' % (filename.replace('\\', '/'), int(line_no)))
            return line.replace(filename,
                                '<a href=\"#%s\" style="color:%s;white-space:pre;">%s</a>' % (link, color, filename))

        try:
            ret = self.trace_reg.sub(_replace_trace_file, text)
        except Exception:
            import konoha_vscript
            konoha_vscript.logger.log_last_except()
            ret = text
        ret = ret.replace('\n', '<br/>')
        return ret

    def _add_text(self, text, msg_type=MessageType.NORMAL):
        """
        添加文本
        Args:
            text: [str]文本内容
            msg_type: [int]MessageType
        Returns:
            None
        """
        if not text:
            return
        self.output_texts.append((msg_type, text))
        if msg_type & self.curr_message_type:
            self.append(text)

    def _truncate_if_exceed(self):
        """
        超过了上限就截断文本
        Returns:
            None
        """
        document = self.document()
        num_blocks = document.lastBlock().blockNumber() - document.firstBlock().blockNumber()
        if num_blocks > self.MAX_LINES:
            to_del_num = num_blocks - self.MAX_LINES
            block = document.firstBlock()
            while block and to_del_num > 0:
                to_del_num -= 1
                cursor = QTextCursor(block)
                block = block.next()
                cursor.select(QTextCursor.SelectionType.BlockUnderCursor)
                cursor.movePosition(QTextCursor.MoveOperation.NextCharacter, QTextCursor.MoveMode.KeepAnchor)
                cursor.removeSelectedText()

    def set_find_widget(self, find_widget):
        """
        设置find widget
        Args:
            find_widget: gui.FindWidget实例
        Returns:
            None
        """
        self.find_widget = find_widget
        self.find_widget.close_clicked.connect(self._stop_find)
        self.find_widget.text_changed.connect(self.find_text)
        self.find_widget.prev_clicked.connect(self.find_prev)
        self.find_widget.next_clicked.connect(self.find_next)

    def on_copy(self):
        """
        复制文本回调
        Returns:
            None
        """
        if self.hasFocus():
            self.copy()

    def on_find(self):
        """
        查找回调
        Returns:
            None
        """
        if not self.find_widget:
            return
        self.find_widget.line_edit.setFocus(Qt.FocusReason.OtherFocusReason)
        self.find_widget.show()
        self.find_text(self.find_widget.get_text())

    def find_text(self, text):
        """
        查找文本
        Args:
            text: [str]文本内容
        Returns:
            None
        """
        if self.search_text:
            self.unhighlight_text(self.search_text)
        if not text:
            return
        self.highlight_text(text)

        cursor = self.textCursor()
        if cursor.hasSelection():
            select_len = len(cursor.selectedText())
            cursor.clearSelection()
            cursor.movePosition(QTextCursor.MoveOperation.Left, QTextCursor.MoveMode.MoveAnchor, select_len)
            self.setTextCursor(cursor)
        self.find(text)
        self.search_text = text

    def highlight_text(self, text):
        """
        highlight文本
        Args:
            text: [str]文本内容
        Returns:
            bool
        """
        brush = QBrush(QColor('#ffff00'))
        return self._find_and_merge_background(text, brush)

    def unhighlight_text(self, text):
        """
        取消highlight文本
        Args:
            text: [str]文本内容
        Returns:
            bool
        """
        brush = QBrush()
        return self._find_and_merge_background(text, brush)

    def _find_and_merge_background(self, text, brush):
        """
        用QBrush改变text的背景色
        Args:
            text: [str]文本内容
            brush: QBrush
        Returns:
            bool
        """
        found = False
        document = self.document()
        cursor = QTextCursor(document)
        highlight_cursor = QTextCursor(document)

        cursor.beginEditBlock()

        while not highlight_cursor.isNull() and not highlight_cursor.atEnd():
            highlight_cursor = document.find(text, highlight_cursor)
            if not highlight_cursor.isNull():
                found = True
                color_format = highlight_cursor.charFormat()
                color_format.setBackground(brush)
                highlight_cursor.mergeCharFormat(color_format)
        
        cursor.endEditBlock()
        
        return found

    def find_next(self):
        """
        寻找下一个文本
        Returns:
            None
        """
        if not self.search_text:
            return
        self.find(self.search_text)

    def find_prev(self):
        """
        寻找上一个文本
        Returns:
            None
        """
        if not self.search_text:
            return
        self.find(self.search_text, QTextDocument.FindFlag.FindBackward)

    def _stop_find(self):
        """
        停止查找
        Returns:
            None
        """
        if self.search_text:
            self.unhighlight_text(self.search_text)
        self.search_text = None
        self.find('#^$#%$')  # 随便找一个不可能被查找的文本
