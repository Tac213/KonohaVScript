# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

from PySide6 import QtCore


class AdvancedQtProperty(object):

    def __init__(self, type_) -> None:
        self.type_ = type_


def _create_getter(attr_name):

    def getter(self):
        return getattr(self, f'_{attr_name}')

    return getter


def _create_setter(attr_name):

    def setter(self, value):
        previous_value = getattr(self, f'_{attr_name}')
        setattr(self, f'_{attr_name}', value)
        getattr(self, f'{attr_name}_changed').emit(previous_value)

    return setter


class QObjectMeta(type(QtCore.QObject)):

    def __new__(cls: type[typing.Self], name: str, bases: tuple[type, ...], namespace: dict[str, typing.Any]) -> typing.Self:
        for attr_name in tuple(namespace.keys()):
            attr_value = namespace[attr_name]
            if isinstance(attr_value, AdvancedQtProperty):
                type_ = attr_value.type_
                getter = _create_getter(attr_name)
                setter = _create_setter(attr_name)
                signal = QtCore.Signal(type_, name=f'{snake_case_to_camel_back(attr_name)}Changed')
                namespace[f'{attr_name}_changed'] = signal
                namespace[attr_name] = QtCore.Property(type_, getter, setter, notify=signal)
        return super().__new__(cls, name, bases, namespace)  # pylint: disable=too-many-function-args


def snake_case_to_camel_back(snake_case: str) -> str:
    char_list = []
    first_char_meet = False
    for idx, char in enumerate(snake_case):
        if char == '_':
            continue
        if idx > 0 and snake_case[idx - 1] == '_' and first_char_meet:
            char = char.upper()
        first_char_meet = True
        char_list.append(char)
    return ''.join(char_list)
