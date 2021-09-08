#!/usr/bin/python3

#  Copyright 2021 Josua Mayer
#  Author Josua Mayer <josua@solid-run.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

import gpiod
from pdudaemon.drivers.driver import PDUDriver

class GPIO(PDUDriver):
    _chip = None
    _line = None

    def __init__(self, hostname, settings):
        self._chip = gpiod.Chip("mcp2221_gpio", gpiod.Chip.OPEN_BY_LABEL)
        self._line = self._chip.get_line(3)
        self._line.request(consumer="pdudaemon", type=gpiod.LINE_REQ_DIR_OUT, flags=0, default_val=0)
        super(GPIO, self).__init__()

    @classmethod
    def accepts(cls, drivername):
        if drivername == "gpio":
            return True
        return False

    def port_interaction(self, command, port_number):
        if command == "off":
            self._line.set_value(0)
        elif command == "on":
            self._line.set_value(1)
        else:
            log.debug("Unknown command!")

    def __del__(self):
        if not self._line is None:
            self._line.release()
        if not self._chip is None:
            self._chip.close()
