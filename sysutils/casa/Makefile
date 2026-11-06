PORTNAME=	casa
DISTVERSION=	0.0.2
CATEGORIES=	sysutils
MASTER_SITES=	https://git.sr.ht/~dch/${PORTNAME}/archive/${DISTVERSIONFULL}${EXTRACT_SUFX}?dummy=/
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Configuration management daemon with Lua policy and a raft cluster
WWW=		https://git.sr.ht/~dch/casa

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE.md

USES=		cargo cmake:indirect
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

post-install:
	@${MKDIR} ${STAGEDIR}${ETCDIR} \
		${STAGEDIR}${PREFIX}/etc/newsyslog.conf.d \
		${STAGEDIR}${PREFIX}/etc/syslog.d \
		${STAGEDIR}/var/db/casa
	${INSTALL_DATA} ${FILESDIR}/casa.ucl.sample ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${FILESDIR}/newsyslog-casa.conf \
		${STAGEDIR}${PREFIX}/etc/newsyslog.conf.d/casa.conf
	${INSTALL_DATA} ${FILESDIR}/casa.syslog.conf \
		${STAGEDIR}${PREFIX}/etc/syslog.d/casa.conf
	${INSTALL_MAN} ${WRKDIR}/casa.1 ${STAGEDIR}${PREFIX}/share/man/man1

post-install-DOCS-on:
	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${PORTDOCS:S,^,${WRKSRC}/,} ${STAGEDIR}${DOCSDIR}

.include <bsd.port.mk>
