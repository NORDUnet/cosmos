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

etcdir = /etc/cosmos
bindir = /usr/bin

all:

install:
	install -D --backup --mode 640 cosmos.conf $(DESTDIR)$(etcdir)/cosmos.conf
	install -D -m 755 cosmos $(DESTDIR)$(bindir)/cosmos
	install -D -m 755 apply.d/10model-test $(DESTDIR)$(etcdir)/apply.d/10model-test
	install -D -m 755 apply.d/20run-pre-tasks $(DESTDIR)$(etcdir)/apply.d/20run-pre-tasks
	install -D -m 755 apply.d/30archive-before-delete $(DESTDIR)$(etcdir)/apply.d/30archive-before-delete
	install -D -m 755 apply.d/40delete $(DESTDIR)$(etcdir)/apply.d/40delete
	install -D -m 755 apply.d/50archive-before-overlay $(DESTDIR)$(etcdir)/apply.d/50archive-before-overlay
	install -D -m 755 apply.d/60overlay $(DESTDIR)$(etcdir)/apply.d/60overlay
	install -D -m 755 apply.d/70run-post-tasks $(DESTDIR)$(etcdir)/apply.d/70run-post-tasks

check:
	checkbashisms --posix --extra cosmos `ls apply.d/* | grep -v 40delete`
	rm -rf tst tst2
	mkdir -p tst2 tst/etc/cosmos tst/var/cache/cosmos/overlay tst/var/cache/cosmos/delete tst/var/cache/cosmos/pre-tasks.d tst/var/cache/cosmos/post-tasks.d
	ln -s `pwd`/apply.d tst/etc/cosmos/
	echo 'foo' > tst/var/cache/cosmos/overlay/foo
	echo 'foo bar' > "tst/var/cache/cosmos/overlay/foo bar"
	echo 'bar\ntest' > "`printf tst/var/cache/cosmos/overlay/bar\\\ntest`"
	echo COSMOS_MODEL=`pwd`/tst/var/cache/cosmos > tst/etc/cosmos/cosmos.conf
	echo COSMOS_ROOT=`pwd`/tst2 >> tst/etc/cosmos/cosmos.conf
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos -n apply
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos -N apply
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos -n -v apply
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos -N -v apply
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos -v apply
	COSMOS_CONF_DIR=`pwd`/tst/etc/cosmos ./cosmos apply
	rm -rf tst tst2

bootstrap:
	@if test -z $$HOST; then \
		echo error: HOST unset; \
		echo "Try 'make bootstrap HOST=12.34.56.78'"; \
		exit 1; \
	fi
	make install DESTDIR=tmp
	rsync -av tmp/ root@$$HOST:/
