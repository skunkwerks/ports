PORTNAME=	patchy
DISTVERSIONPREFIX=	v
DISTVERSION=	0.1.0
CATEGORIES=	www devel
MASTER_SITES=	https://github.com/skunkwerks/patchy/releases/download/${DISTVERSIONPREFIX}${DISTVERSION}/
DISTNAME=	${PORTNAME}-${DISTVERSION}-port

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Code review, compatible with Phorge and Phabricator
WWW=		https://github.com/skunkwerks/patchy

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${_ERLANG}/bin/erl:lang/erlang-runtime29 \
		cargo:lang/rust
RUN_DEPENDS=	${_ERLANG}/bin/erl:lang/erlang-runtime29

USES=		cmake:indirect gmake

USE_RC_SUBR=	patchy

MAKE_ENV=	CARGO_HOME=${WRKDIR}/.cargo \
		GMAKE=${GMAKE} \
		HOME=${WRKDIR} \
		PATH=${_ERLANG}/bin:${PATH}

ETCDIR=		${PREFIX}/etc/${PORTNAME}
SUB_FILES=	pkg-message
SUB_LIST=	ERLANG=${_ERLANG} \
		RELEASE=${_RELEASE}

WRKSRC=		${WRKDIR}/${PORTNAME}-${DISTVERSION}

PORTDOCS=	README.md

OPTIONS_DEFINE=	DOCS

_ERLANG=	${LOCALBASE}/lib/erlang29
_RELEASE=	${PREFIX}/libexec/${PORTNAME}

# The tarball is the release as `make tarball` packs it upstream: every
# application compiled, without the Erlang runtime and without the three
# NIF shared objects, which nifs/build.sh makes here.
do-build:
	(cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${SH} nifs/build.sh)

do-install:
	${MKDIR} ${STAGEDIR}${_RELEASE}
.for dir in bin lib releases
	${CP} -a ${WRKSRC}/${dir} ${STAGEDIR}${_RELEASE}/
.endfor
	${FIND} ${STAGEDIR}${_RELEASE}/lib -type f -name '*.so' \
		-exec ${STRIP_CMD} {} \;
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${WRKSRC}/freebsd/${PORTNAME}.env.sample \
		${STAGEDIR}${ETCDIR}/${PORTNAME}.env.sample
	${MKDIR} ${STAGEDIR}/var/db/${PORTNAME}

do-install-DOCS-on:
	${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${DOCSDIR}/

# the release's files, with their application versions, go in the plist
# here rather than by hand
post-install:
	@cd ${STAGEDIR}${PREFIX} && \
		${FIND} libexec/${PORTNAME} -type f -o -type l | \
		${SORT} >> ${TMPPLIST}

.include <bsd.port.mk>
