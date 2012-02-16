# Copyright (C) 2012 Simon Josefsson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

etcdir = /etc/eve
bindir = /usr/bin

all:

install:
	install -D --backup --mode 640 eve.conf $(DESTDIR)$(etcdir)/eve.conf
	install -D -m 644 eve $(DESTDIR)$(bindir)/eve
	install -D -m 644 overlay.d/10model-test $(DESTDIR)$(etcdir)/overlay.d/10model-test
	install -D -m 644 overlay.d/20archive $(DESTDIR)$(etcdir)/overlay.d/20archive
	install -D -m 644 overlay.d/30rsync $(DESTDIR)$(etcdir)/overlay.d/30rsync

check:
	checkbashisms eve overlay.d/*

bootstrap:
	@if test -z $$HOST; then \
		echo error: HOST unset; \
		echo Try 'make bootstrap HOST=foobar.example.org'; \
	fi
	make install DESTDIR=tmp
	rsync -av tmp/ root@$$HOST:/
