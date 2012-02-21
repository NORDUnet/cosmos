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

VERSION=1.0

DESTDIR?=
prefix=/usr
bindir=${prefix}/bin
etcdir=/etc
mandir=${prefix}/share/man

INSTALL=install
INSTALL_EXE=$(INSTALL) -D --mode 755
INSTALL_DATA=$(INSTALL) -D --mode 0644

D_APPLY=apply.d/10model-test apply.d/20run-pre-tasks		\
	apply.d/30archive-before-delete apply.d/40delete	\
	apply.d/50archive-before-overlay apply.d/60overlay	\
	apply.d/70run-post-tasks
D_CLONE=clone.d/10repo-test clone.d/20clone-git clone.d/90repo-check
D_UPDATE=update.d/10repo-test update.d/20update-git
D_GPG=gpg.d/50gpg

all: cosmos.1

cosmos.1: Makefile cosmos
	help2man --name="simple Configuration Management System" \
		--no-info --no-discard-stderr --output=$@ ./cosmos

dist: all
	rm -rf cosmos-$(VERSION)
	mkdir cosmos-$(VERSION)
	cp -r debian COPYING AUTHORS NEWS Makefile README cosmos cosmos.conf cosmos.1 apply.d clone.d update.d gpg.d cosmos-$(VERSION)/
	tar cfz cosmos-$(VERSION).tar.gz cosmos-$(VERSION)
	rm -rf cosmos-$(VERSION)

install: all
	$(INSTALL) -D --backup --mode 640 cosmos.conf $(DESTDIR)$(etcdir)/cosmos/cosmos.conf
	$(INSTALL_EXE) cosmos $(DESTDIR)$(bindir)/cosmos
	$(INSTALL) -D cosmos.1 $(DESTDIR)$(mandir)/man1/cosmos.1
	for f in $(D_APPLY) $(D_CLONE) $(D_UPDATE) $(D_GPG); do \
		$(INSTALL_EXE) $$f $(DESTDIR)$(etcdir)/cosmos/$$f; \
	done

clean:
	rm -f cosmos.1

check:
	grep '^cosmos (Cosmos)' cosmos | grep -q "^cosmos (Cosmos) $(VERSION)$$"
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

distcheck: dist
	rm -rf cosmos-$(VERSION)
	tar xfz cosmos-$(VERSION).tar.gz
	cd cosmos-$(VERSION)
	make install DESTDIR=ff
	make check
	cd ..
	rm -rf cosmos-$(VERSION)

bootstrap:
	@if test -z $$HOST; then \
		echo error: HOST unset; \
		echo "Try 'make bootstrap HOST=12.34.56.78'"; \
		exit 1; \
	fi
	make install DESTDIR=tmp
	rsync -av tmp/ root@$$HOST:/
