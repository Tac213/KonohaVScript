# -*- coding: utf-8 -*-
# author: Tac
# contact: cookiezhx@163.com

import typing

import shortuuid


class HierarchyItem(object):

    def __init__(self,
                 item_id: typing.Optional[str] = None,
                 data: typing.Optional[typing.Dict[str, typing.Any]] = None,
                 parent: typing.Optional['HierarchyItem'] = None) -> None:
        self.item_id = item_id
        if not self.item_id:
            self.item_id = shortuuid.uuid()
        self.parent = parent
        self.children = []  # type: typing.List[HierarchyItem]
        self.var_name = ''
        self._init_data(data or {})

    def _init_data(self, data: typing.Dict[str, typing.Any]) -> None:
        var_name = data.get('var_name')
        if var_name:
            self.var_name = var_name

    def get_data(self) -> typing.Dict[str, typing.Any]:
        return {
            'var_name': self.var_name,
        }

    def add_child(self, child: 'HierarchyItem') -> None:
        child.parent = self
        self.children.append(child)

    def insert_child(self, index: int, child: 'HierarchyItem') -> None:
        child.parent = self
        self.children.insert(index, child)

    def remove_child_at(self, index: int) -> None:
        del self.children[index]

    def remove_child(self, child: 'HierarchyItem') -> None:
        if child not in self.children:
            return
        self.children.remove(child)

    def children_count(self) -> int:
        return len(self.children)

    def row(self) -> int:
        if not self.parent:
            return -1
        return self.parent.children.index(self)

    def clone(self) -> 'HierarchyItem':
        new_item = self.__class__(data=self.get_data(), parent=self.parent)
        for child in self.children:
            new_item.children.append(child.clone())
        return new_item

    def serialize(self) -> typing.Dict[str, typing.Any]:
        serialized_data = {
            'item_id': self.item_id,
            'data': self.get_data(),
            'children': [child.serialize() for child in self.children],
        }
        return serialized_data

    @classmethod
    def deserialize(cls, serialized_data: typing.Dict[str, typing.Any], parent: typing.Optional['HierarchyItem'] = None) -> 'HierarchyItem':
        hierarchy_item = cls(serialized_data.get('item_id'), serialized_data.get('data'), parent)
        for child_serialized_data in serialized_data.get('children', ()):
            hierarchy_item.add_child(cls.deserialize(child_serialized_data, hierarchy_item))
        return hierarchy_item
