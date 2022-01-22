# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com


import logging
import logging.handlers
import sys
import traceback
import platform
import types
import time


def compact_traceback():
    """
    获取exception信息
    Returns:
        tuple
        0: tuple
            0: str, exception所在文件名
            1: str, exception所在函数名
            2: str, exception所在行号
        1: exception类型
        2: exception参数
        3: str, traceback信息
    """
    exception, arg, tb = sys.exc_info()
    if tb is None:
        return
    tb_info = []
    while tb:
        tb_info.append((
            tb.tb_frame.f_code.co_filename,
            tb.tb_frame.f_code.co_name,
            str(tb.tb_lineno),
        ))
        tb = tb.tb_next
    del tb

    info = ' '.join(['[%s|%s|%s]' % t for t in tb_info])
    return tb_info[-1], exception, arg, info


def log_compact_traceback(logger, skip_frame=0, max_frame=30):
    """
    默认的log_last_except方法
    Args:
        logger: logger
        skip_frame: [int]跳过的PyFrameObject数量
        max_frame: [int]最大的PyFrameObject数量
    Returns:
        str, traceback信息
    """
    stack = ['\n>>>>>>>>>> TRACEBACK >>>>>>>>>>\n', 'Traceback\n']
    exception, arg, tb = sys.exc_info()
    if exception:
        stack.append('%s: %s\n' % (exception.__name__, arg))
    if tb:
        stack.extend(traceback.format_tb(tb, max_frame))
    else:
        stack.extend(traceback.format_stack(None, max_frame))
        skip_frame += 1
    if skip_frame > 0:
        stack = stack[:-skip_frame]
    stack.append('<<<<<<<<<<<<< END <<<<<<<<<<<<<\n')
    stack_str = ''.join(stack)
    logger.error(stack_str)
    return stack_str


# log级别定义，从高到低
CRITICAL = logging.CRITICAL
ERROR = logging.ERROR
WARNING = logging.WARNING
WARN = logging.WARN
INFO = logging.INFO
DEBUG = logging.DEBUG


# 日志输出流
STREAM = 'stream'
SYSLOG = 'syslog'
FILE = 'file'


class LogManager(object):
    created_loggers = set()  # 已经有的logger名
    level = DEBUG  # log等级
    handler = STREAM  # log输出Handler
    tag = ''  # 日志的tag
    sys_logger = None

    @classmethod
    def get_logger(cls, logger_name, save_file=False, dirname=None):
        """
        获取logger对象
        Args:
            logger_name: [str]logger名字
            save_file: [bool]是否保存文件
            dirname: [str]文件保存的目录名
        Returns:
            logger对象
        """
        if cls.handler == SYSLOG and platform.system() == 'Linux' and cls.sys_logger is not None:
            return logging.LoggerAdapter(cls.sys_logger, {'modulename': logger_name})

        if logger_name in cls.created_loggers:
            return logging.getLogger(logger_name)

        logger = logging.getLogger(logger_name)
        # 为logger实例绑定一个log_last_except的方法
        logger.log_last_except = types.MethodType(log_compact_traceback, logger)
        logger.setLevel(cls.level)
        logger.addHandler(cls._create_handler(logger, save_file, dirname))
        cls.created_loggers.add(logger_name)

        if cls.handler == SYSLOG and platform.system() == 'Linux' and cls.sys_logger is not None:
            # 做两次判断，因为可能中途在_CreateHandler的时候sys_logger创建出来了
            return logging.LoggerAdapter(cls.sys_logger, {'modulename': logger_name})

        return logger

    @classmethod
    def _create_handler(cls, logger, save_file=False, dirname=None):
        """
        创建handler
        Args:
            logger: logger对象
            save_file: [bool]是否保存文件
            dirname: [str]文件保存的目录名
        Returns:
            handler对象
        """
        con = ' - '
        # 可以用的key参考logging源码Formatter类的注释
        format_list = ['%(asctime)s', cls.tag, '%(levelname)s', '%(message)s']
        if cls.handler == SYSLOG:
            if platform.system() == 'Linux':
                handler = logging.handlers.SysLogHandler('/dev/log', facility=logging.handlers.SysLogHandler.LOG_LOCAL1)
                cls.sys_logger = logger
            else:
                handler = logging.FileHandler(cls.tag + '_' + time.strftime('%Y%m%d_%H%M%S') + '.log', encoding='utf-8')
        elif save_file:
            if dirname:
                filename = dirname + '/' + cls.tag + '_' + time.strftime('%Y%m%d_%H%M%S') + '.log'
            else:
                filename = cls.tag + '_' + time.strftime('%Y%m%d_%H%M%S') + '.log'
            handler = logging.FileHandler(filename, encoding='utf-8')
        else:
            # handler = logging.StreamHandler(sys.stdout)
            handler = OutputWindowHandler()

        handler.setLevel(cls.level)
        formatter = logging.Formatter(con.join(format_list))
        handler.setFormatter(formatter)
        return handler

    @classmethod
    def set_level(cls, level):
        """
        设置log等级
        Args:
            level: int
        Returns:
            None
        """
        cls.level = level
        for logger_name in cls.created_loggers:
            logging.getLogger(logger_name).setLevel(level)

    @classmethod
    def set_handler(cls, handler):
        """
        设置Handler类型
        Args:
            handler: str
        Returns:
            None
        """
        cls.handler = handler
        for logger_name in cls.created_loggers:
            logger = logging.getLogger(logger_name)
            logger.addHandler(cls._create_handler(logger))

    @classmethod
    def set_tag(cls, tag):
        """
        设置tag
        Args:
            tag: str
        Returns:
            None
        """
        cls.tag = tag
        for logger_name in cls.created_loggers:
            logger = logging.getLogger(logger_name)
            logger.addHandler(cls._create_handler(logger))


class OutputWindowHandler(logging.Handler):
    """
    将log输出到Output窗口
    """
    main_window_ready = False

    def emit(self, record: logging.LogRecord):
        """
        重载emit
        Args:
            record: logging.LogRecord
        Returns:
            None
        """
        message = self.format(record)
        if self.main_window_ready:
            try:
                import gui.main_window
                if record.levelno >= logging.ERROR:
                    gui.main_window.main_window.console_window.show_error_message(message)
                elif record.levelno == logging.WARNING:
                    gui.main_window.main_window.console_window.show_warning_message(message)
                else:
                    gui.main_window.main_window.console_window.show_normal_message(message)
            except Exception:
                import traceback
                message = 'OutputWindow Exception:\n%s\nOriginal message: %s\n' % (traceback.format_exc(), message)
                sys.stderr.write(message)
                self.handleError(record)
        # 无论main window是否创建完成，都走StreamHandler的逻辑输出到stream
        try:
            if record.levelno >= logging.ERROR:
                sys.__stderr__.write(message + '\n')
            else:
                sys.__stdout__.write(message + '\n')
            self.flush()
        except RecursionError:
            raise
        except Exception:
            self.handleError(record)

    def flush(self):
        """
        flushed the stream
        Returns:
            None
        """
        self.acquire()
        try:
            sys.stderr.flush()
        finally:
            self.release()


class MockStdOut(object):
    """
    Mock stdout和stderr
    """

    def __init__(self, channel, origin, output_window=None):
        """
        构造器
        Args:
            channel: [str]'stdout'或者'stderr'
            origin: sys.stdout或sys.stderr
            output_window: 指定输出窗口
        """
        self.channel = channel
        self.origin = origin
        self.output_window = output_window
        self._buffer = ''

    def __getattr__(self, attr_name):
        """
        获取属性
        Args:
            attr_name: [str]属性名
        Returns:
            对应的值
        """
        return object.__getattribute__(self.origin, attr_name)

    def write(self, text):
        """
        输出回调
        Args:
            text: [str]输出内容
        Returns:
            None
        """
        self.origin.write(text)

        self._buffer += text
        if self._buffer.endswith('\n'):
            self._buffer = self._buffer.rstrip('\n')
            if not self.output_window:
                import gui.main_window
                if gui.main_window.main_window:
                    if self.channel == 'stdout':
                        gui.main_window.main_window.console_window.show_normal_message(self._buffer)
                    else:
                        gui.main_window.main_window.console_window.show_error_message(self._buffer)
            else:
                if self.channel == 'stdout':
                    self.output_window.show_normal_message(self._buffer)
                else:
                    self.output_window.show_error_message(self._buffer)
            self._buffer = ''


sys.stdout = MockStdOut('stdout', sys.__stdout__)
sys.stderr = MockStdOut('stderr', sys.__stderr__)
