PORTNAME=	rea
DISTVERSION=	6.5.0
CATEGORIES=	security
MASTER_SITES=	LOCAL/dch/${PORTNAME}/:npm \
		https://codeload.github.com/morluto/rea/tar.gz/refs/tags/rea-agents-${DISTVERSION}?dummy=/:src
DISTFILES=	${_NPM_ARCHIVE}:npm \
		rea-agents-${DISTVERSION}.tar.gz:src
DIST_SUBDIR=	${PORTNAME}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Local reverse-engineering CLI and MCP server
WWW=		https://github.com/morluto/rea

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

ONLY_FOR_ARCHS=	aarch64 amd64

BUILD_DEPENDS=	npm:www/npm-node${_NODE_VERSION}
USES=		nodejs:${_NODE_VERSION},run python:build tar:xz

SUB_FILES=	rea
SUB_LIST=	DATADIR=${DATADIR} \
		LOCALBASE=${LOCALBASE}

PLIST_FILES=	bin/rea

_NODE_VERSION=	26

_CACHE_TAG=	20261015
_NPM_CACHE=	${WRKDIR}/cache
_NPM_ARCHIVE=	${PORTNAME}-npm-cache-${DISTVERSION}-${_CACHE_TAG}${EXTRACT_SUFX}

.include <bsd.port.pre.mk>

# gh's codeload tarball unpacks to <repo>-<tag>; map it to a stable WRKSRC.
WRKSRC=		${WRKDIR}/rea-rea-agents-${DISTVERSION}

do-extract:
	@${MKDIR} ${_NPM_CACHE}
	${TAR} -xf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE}
	@${MKDIR} ${WRKSRC}
	${TAR} -xf ${_DISTDIR}/rea-agents-${DISTVERSION}.tar.gz \
		-C ${WRKDIR}

do-build:
# scrub MAKEFLAGS/MFLAGS as it breaks node-gyp; turbo cannot run on FreeBSD,
# so run the two compile steps directly instead of `npm run build:cached`
	@(cd ${WRKSRC} && ${SETENV} -u MAKEFLAGS -u MFLAGS \
		HOME=${WRKDIR} npm_config_cache=${_NPM_CACHE} \
		npm_config_devdir=${_NPM_CACHE} npm_config_nodedir=${PREFIX} \
		npm ci --ignore-scripts --no-audit --no-fund \
		--cache ${_NPM_CACHE} --prefer-offline --offline)
	@(cd ${WRKSRC} && ${SETENV} HOME=${WRKDIR} \
		npm_config_cache=${_NPM_CACHE} \
		npm run compile)
	@(cd ${WRKSRC} && ${SETENV} HOME=${WRKDIR} \
		node scripts/generate-skill-metadata.mjs)

do-install:
	${INSTALL_SCRIPT} ${WRKDIR}/rea \
		${STAGEDIR}${PREFIX}/bin/rea
	${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_DATA} ${WRKSRC}/package.json \
		${STAGEDIR}${DATADIR}/package.json
# rea.mjs resolves its package root relative to import.meta.url, so the whole
# runtime tree (compiled dist/, provider bridges, scripts, generated skills,
# and the external node_modules) must sit together under DATADIR
	cd ${WRKSRC} && \
		for d in dist bridge scripts skills node_modules; do \
			${COPYTREE_SHARE} $$d ${STAGEDIR}${DATADIR}; \
		done

post-install:
# the runtime tree has content-hashed/varying names; list it at package time
# rather than hand-maintaining it in pkg-plist
	@${FIND} -s \
		${STAGEDIR}${DATADIR} \
		-not -type d | \
		${SED} -e 's|^${STAGEDIR}${PREFIX}/||' \
		>> ${TMPPLIST}

# Basic functional tests: the launcher starts and reports its version, and
# the MCP server answers an initialize handshake over stdio.
_TEST_DIR=	${WRKDIR}/reatest

do-test:
	${STAGEDIR}${PREFIX}/bin/rea --version | \
		${GREP} -qx ${DISTVERSION}
	${PRINTF} '%s\n%s\n' \
		'{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"port","version":"0"}}}' \
		'{"jsonrpc":"2.0","method":"notifications/initialized"}' | \
		${STAGEDIR}${PREFIX}/bin/rea --mcp | \
		${GREP} -q '"result"'
	@${ECHO_MSG} "===> rea functional tests passed"

# maintainer flow: regenerate the npm cache distfile and distinfo
# bump _CACHE_TAG first: archives are rebuilt & must not reuse a published name
# make _tarball                      # rebuild the LOCAL distfile & distinfo
# make _upload                       # push it to freefall

_tarball: build-depends
	@if [ -f ${_DISTDIR}/${_NPM_ARCHIVE} ]; then \
		${ECHO_CMD} "===> distfile for _CACHE_TAG=${_CACHE_TAG} already exists;"; \
		${ECHO_CMD} "===> bump _CACHE_TAG before rebuilding it"; \
		exit 1; \
		fi
	${RM} -rf ${_NPM_CACHE}
	@${MKDIR} ${WRKDIR} ${_NPM_CACHE} ${_DISTDIR}
	(cd ${WRKSRC} && ${SETENV} HOME=${WRKDIR} \
		npm_config_cache=${_NPM_CACHE} \
		npm ci --ignore-scripts --no-audit --no-fund \
		--cache ${_NPM_CACHE} --prefer-offline)
	${TAR} -caf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE} _cacache
	${CHMOD} 644 ${_DISTDIR}/${_NPM_ARCHIVE}
	cd ${.CURDIR} && ${MAKE} makesum
	@${ECHO_MSG} "===> distinfo updated; run \"make _upload\" to publish"

_upload:
	rsync -Phriv --times --chmod=F644 ${_DISTDIR}/${_NPM_ARCHIVE} \
		freefall.freebsd.org:public_distfiles/${PORTNAME}/

.include <bsd.port.post.mk>
