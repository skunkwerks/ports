PORTNAME=	casa
DISTVERSION=	0.0.27
CATEGORIES=	sysutils
MASTER_SITES=	LOCAL/dch/
DISTFILES=	casa/${DISTNAME}${EXTRACT_SUFX}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Configuration management daemon with Lua policy and a raft cluster
WWW=		https://github.com/dch/casa

LICENSE=	APACHE20 BSD2CLAUSE BSD3CLAUSE ISCL MIT UNICODE3
LICENSE_COMB=	multi
LICENSE_NAME_UNICODE3=	Unicode License v3
LICENSE_FILE=	${WRKSRC}/LICENSE.md
LICENSE_PERMS_UNICODE3=	dist-mirror dist-sell pkg-mirror pkg-sell auto-accept

USES=		cargo cmake:indirect tar:xz
USE_RC_SUBR=	casa

CARGO_INSTALL_PATH=	casa
# The bundled libucl asks for CMake 2.8, which CMake 4 refuses.
CARGO_ENV=		CMAKE_POLICY_VERSION_MINIMUM=3.5

SUB_FILES=	pkg-message

PLIST_FILES=	"@dir(root,wheel,0700) /var/db/casa" \
		"@sample ${ETCDIR}/casa.ucl.sample" \
		bin/casa \
		etc/newsyslog.conf.d/casa.conf \
		etc/syslog.d/casa.conf \
		share/man/man1/casa.1.gz
PORTDOCS=	CHANGELOG.md DESIGN.md LICENSE.md README.md USAGE.md

OPTIONS_DEFINE=	DOCS

post-build:
	${CARGO_TARGET_DIR}/release/casa --manpage > ${WRKDIR}/casa.1
	${CARGO_TARGET_DIR}/release/casa config generate > ${WRKDIR}/casa.ucl.sample

post-install:
	@${MKDIR} ${STAGEDIR}${ETCDIR} \
		${STAGEDIR}${PREFIX}/etc/newsyslog.conf.d \
		${STAGEDIR}${PREFIX}/etc/syslog.d \
		${STAGEDIR}/var/db/casa
	${INSTALL_DATA} ${WRKDIR}/casa.ucl.sample ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${WRKSRC}/contrib/freebsd/${PKGORIGIN}/files/newsyslog-casa.conf \
		${STAGEDIR}${PREFIX}/etc/newsyslog.conf.d/casa.conf
	${INSTALL_DATA} ${WRKSRC}/contrib/freebsd/${PKGORIGIN}/files/casa.syslog.conf \
		${STAGEDIR}${PREFIX}/etc/syslog.d/casa.conf
	${INSTALL_MAN} ${WRKDIR}/casa.1 ${STAGEDIR}${PREFIX}/share/man/man1

post-install-DOCS-on:
	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${PORTDOCS:S,^,${WRKSRC}/,} ${STAGEDIR}${DOCSDIR}

# A maintainer target, run from the port's place in the casa tree:
#
#   make _tarball	the source archive of the tag DISTVERSION, from
#			git archive of this tree, then makesum. The
#			repository is private, so no site serves the
#			archive. It stays in this host's distfiles
#			cache, where poudriere reads it.
_CASA_TREE?=	${.CURDIR}/../../../..

_tarball:
	${MKDIR} ${_DISTDIR}/casa
	git -C ${_CASA_TREE} archive --format=tar --prefix=${DISTNAME}/ \
		${DISTVERSIONFULL} | ${XZ_CMD} > ${_DISTDIR}/casa/${DISTNAME}${EXTRACT_SUFX}
	${CHMOD} 644 ${_DISTDIR}/casa/${DISTNAME}${EXTRACT_SUFX}
	cd ${.CURDIR} && ${MAKE} makesum

.include <bsd.port.mk>
