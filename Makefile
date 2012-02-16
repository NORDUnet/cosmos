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
	install -D -m 644 apply.d/10model-test $(DESTDIR)$(etcdir)/apply.d/10model-test
	install -D -m 644 apply.d/20run-pre-tasks $(DESTDIR)$(etcdir)/apply.d/20run-pre-tasks
	install -D -m 644 apply.d/30archive-before-delete $(DESTDIR)$(etcdir)/apply.d/30archive-before-delete
	install -D -m 644 apply.d/40delete $(DESTDIR)$(etcdir)/apply.d/40delete
	install -D -m 644 apply.d/50archive-before-overlay $(DESTDIR)$(etcdir)/apply.d/50archive-before-overlay
	install -D -m 644 apply.d/60overlay $(DESTDIR)$(etcdir)/apply.d/60overlay
	install -D -m 644 apply.d/70run-post-tasks $(DESTDIR)$(etcdir)/apply.d/70run-post-tasks

check:
	checkbashisms eve apply.d/*

bootstrap:
	@if test -z $$HOST; then \
		echo error: HOST unset; \
		echo Try 'make bootstrap HOST=foobar.example.org'; \
	fi
	make install DESTDIR=tmp
	rsync -av tmp/ root@$$HOST:/
