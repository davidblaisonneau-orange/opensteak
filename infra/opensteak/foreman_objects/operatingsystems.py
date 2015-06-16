#!/usr/bin/python3
# -*- coding: utf-8 -*-
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#    Authors:
#     David Blaisonneau <david.blaisonneau@orange.com>
#     Arnaud Morin <arnaud1.morin@orange.com>

from opensteak.foreman_objects.objects import ForemanObjects
from opensteak.foreman_objects.item import ForemanItem


class OperatingSystems(ForemanObjects):
    """
    OperatingSystems class
    """
    objName = 'operatingsystems'
    payloadObj = 'operatingsystem'

    def __getitem__(self, key):
        """ Function __getitem__

        @param key: The operating system id/name
        @return RETURN: The item
        """
        return ForemanItem(self, key, self.api.list(self.objName, filter='title = "{}"'.format(key))[0])

    def __setitem__(self, key, attributes):
        """ Function __getitem__

        @param key: The operating system id/name
        @param attributes: The content of the operating system to create
        @return RETURN: The API result
        """
        if key not in self:
            payload = {self.payloadObj: {'title': key}}
            payload[self.payloadObj].update(attributes)
            return self.api.create(self.objName, payload)
        return False