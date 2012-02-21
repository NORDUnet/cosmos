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

DESTDIR?=
prefix=/usr
bindir=${prefix}/bin
etcdir=/etc
mandir=${prefix}/share/man

INSTALL=install
INSTALL_EXE=$(INSTALL) -D --mode 755
INSTALL_DATA=$(INSTALL) -D --mode 0644

all: cosmos.1

cosmos.1: Makefile cosmos
	help2man --name="simple Configuration Management System" \
		--no-info --no-discard-stderr --output=$@ ./cosmos

dist: all
	rm -rf cosmos-1.0
	mkdir cosmos-1.0
	cp -r debian COPYING AUTHORS NEWS Makefile README cosmos cosmos.conf cosmos.1 apply.d clone.d update.d gpg.d cosmos-1.0/
	tar cfz cosmos-1.0.tar.gz cosmos-1.0
	rm -rf cosmos-1.0

install: all
	$(INSTALL) -D --backup --mode 640 cosmos.conf $(DESTDIR)$(etcdir)/cosmos/cosmos.conf
	$(INSTALL_EXE) cosmos $(DESTDIR)$(bindir)/cosmos
	$(INSTALL_EXE) apply.d/10model-test $(DESTDIR)$(etcdir)/cosmos/apply.d/10model-test
	$(INSTALL_EXE) apply.d/20run-pre-tasks $(DESTDIR)$(etcdir)/cosmos/apply.d/20run-pre-tasks
	$(INSTALL_EXE) apply.d/30archive-before-delete $(DESTDIR)$(etcdir)/cosmos/apply.d/30archive-before-delete
	$(INSTALL_EXE) apply.d/40delete $(DESTDIR)$(etcdir)/cosmos/apply.d/40delete
	$(INSTALL_EXE) apply.d/50archive-before-overlay $(DESTDIR)$(etcdir)/cosmos/apply.d/50archive-before-overlay
	$(INSTALL_EXE) apply.d/60overlay $(DESTDIR)$(etcdir)/cosmos/apply.d/60overlay
	$(INSTALL_EXE) apply.d/70run-post-tasks $(DESTDIR)$(etcdir)/cosmos/apply.d/70run-post-tasks
	$(INSTALL_EXE) clone.d/10repo-test $(DESTDIR)$(etcdir)/cosmos/clone.d/10repo-test
	$(INSTALL_EXE) clone.d/20clone-git $(DESTDIR)$(etcdir)/cosmos/clone.d/20clone-git
	$(INSTALL_EXE) clone.d/90repo-check $(DESTDIR)$(etcdir)/cosmos/clone.d/90repo-check
	$(INSTALL_EXE) update.d/10repo-test $(DESTDIR)$(etcdir)/cosmos/update.d/10repo-test
	$(INSTALL_EXE) update.d/20update-git $(DESTDIR)$(etcdir)/cosmos/update.d/20update-git
	$(INSTALL_EXE) gpg.d/50manage $(DESTDIR)$(etcdir)/cosmos/update.d/50manage
	$(INSTALL) -D cosmos.1 $(DESTDIR)$(mandir)/man1/cosmos.1

clean:
	rm -f cosmos.1

check:
	checkbashisms --posix --extra cosmos `ls apply.d/* | grep -v 40delete` clone.d/* update.d/* gpg.d/*
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
