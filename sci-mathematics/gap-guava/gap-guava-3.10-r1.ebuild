# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

MY_PN="guava"

DESCRIPTION="GUAVA is a package that implements coding theory algorithms in GAP"
HOMEPAGE="http://sage.math.washington.edu/home/wdj/guava/"
SRC_URI="http://sage.math.washington.edu/home/wdj/${MY_PN}/${MY_PN}${PV}.tar.bz2"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

DEPEND="sci-mathematics/gap"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_PN}${PV}"

src_prepare() {
	# adds stdlib.h which is needed because of "exit" - fixes QA warning
	epatch "${FILESDIR}"/${P}-fix-missing-header.patch

	cd lib
	rm *~ || die "failed to remove backup files"
}

src_configure() {
	# not a true configuration script from autoconf
	./configure /usr/share/gap || die "configuration failed"
}

src_compile() {
	emake CFLAGS="${CFLAGS}" COMPOPT="-c ${CFLAGS}" || die
}

src_install() {
	source /usr/share/gap/sysinfo.gap
	rm bin/${GAParch}/*.o || die "failed to remove object files"

	exeinto /usr/share/gap/pkg/${MY_PN}/bin
	doexe bin/desauto bin/wtdist || die

	exeinto /usr/share/gap/pkg/${MY_PN}/bin/leon
	doexe bin/leon/* || die

	exeinto /usr/share/gap/pkg/${MY_PN}/bin/${GAParch}
	doexe bin/${GAParch}/* || die

	insinto /usr/share/gap/pkg/${MY_PN}
	doins -r lib tbl guava_gapdoc.gap init.g PackageInfo.g read.g || die
	dodoc README.guava COPYING.guava || die

	if use doc ; then
		dohtml htm/* || die
		dodoc doc/manual.pdf src/leon/doc/leon_guava_manual.pdf || die
	fi
}