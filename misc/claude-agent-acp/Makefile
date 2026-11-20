PORTNAME=	claude-agent-acp
DISTVERSIONPREFIX=	v
DISTVERSION=	0.99.2
DISTVERSIONSUFFIX=	-preview.7
CATEGORIES=	misc # machine-learning
MASTER_SITES=	LOCAL/dch/${PORTNAME}/:npm
DISTFILES=	${_NPM_ARCHIVE}:npm
DIST_SUBDIR=	${PORTNAME}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Agent Client Protocol adapter for Claude Code, as a single executable
WWW=		https://github.com/agentclientprotocol/claude-agent-acp

# the adapter and the ACP SDK are Apache-2.0, zod is MIT, and the bundled
# @anthropic-ai/claude-agent-sdk is proprietary, as for misc/claude-code
LICENSE=	ANTHROPIC APACHE20 MIT
LICENSE_COMB=	multi
LICENSE_NAME_ANTHROPIC=	Anthropic Proprietary License
LICENSE_FILE_ANTHROPIC=	${FILESDIR}/LICENSE.anthropic
LICENSE_PERMS_ANTHROPIC=	dist-mirror pkg-mirror auto-accept

# the adapter drives misc/claude-code, which is a Linux binary
ONLY_FOR_ARCHS=	aarch64 amd64
ONLY_FOR_ARCHS_REASON=	requires misc/claude-code

# The final package is a PIE node26 binary with a customised archive that
# contains the bundled JavaScript appended to it. Only that interpreter is
# pinned: npm, and the node it runs on, follow the default version, as
# misc/claude-code does, so the two never bring conflicting node packages
# into one jail. node26-sea installs a single binary under its own name and
# sits beside any www/node2x.
BUILD_DEPENDS=	${_SEA_NODE}:www/node${_NODE_VERSION}-sea
# sync with the NodeJS dependencies: the executable is a copy of the
# node26-sea interpreter, so it needs everything that one links against
LIB_DEPENDS=	libada.so:devel/libada \
		libbrotlidec.so:archivers/brotli \
		libcares.so:dns/c-ares \
		libffi.so:devel/libffi \
		libhdr_histogram.so:graphics/hdr_histogram \
		libicui18n.so:devel/icu \
		libllhttp.so:www/llhttp \
		libmerve.so:devel/merve \
		libnbytes.so:www/nbytes \
		libnghttp2.so:www/libnghttp2 \
		libnghttp3.so:www/libnghttp3 \
		libngtcp2.so:net/libngtcp2 \
		libsimdjson.so:devel/simdjson \
		libsqlite3.so:databases/sqlite3 \
		libuv.so:devel/libuv \
		libuvwasi.so:devel/uvwasi \
		libzstd.so:archivers/zstd
RUN_DEPENDS=	claude:misc/claude-code
TEST_DEPENDS=	claude:misc/claude-code
USES=		nodejs:build npm:npm,build ssl tar:txz

# %%PREFIX%% in pkg-message is only substituted for a generated one
SUB_FILES=	pkg-message

# a single file, so there are no directories to share with any other port
PLIST_FILES=	bin/${PORTNAME}

_ESBUILD_VER=	0.28.2
_NODE_VERSION=	26
# the npm package carries the full version, suffix included; a bare
# ${DISTVERSION} does not exist on the registry
_NPM_PKGVERSION=	${DISTVERSION}${DISTVERSIONSUFFIX}
# the interpreter that injects the blob, and that the executable is a copy of
_SEA_NODE=	node${_NODE_VERSION}-sea

_CACHE_TAG=	202610302345
_NPM_CACHE=	${WRKDIR}/cache
_NPM_ARCHIVE=	${PORTNAME}-npm-cache-${DISTVERSION}-${_CACHE_TAG}${EXTRACT_SUFX}
_NPM_TREE=	${WRKDIR}/npmtree
_TOOLS=		${WRKDIR}/tools
_SEA_OUT=	${WRKDIR}/sea

do-extract:
	@${MKDIR} ${_NPM_CACHE}
	${TAR} -xf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE}

do-build:
# because nodejs is fiddly we can't build & then install
	${ECHO_CMD} offline=true > ${WRKDIR}/.npmrc
# npm's self-update check ignores offline=true; keep the build off the network
	${ECHO_CMD} update-notifier=false >> ${WRKDIR}/.npmrc
# nothing in the closure needs an install script, so npm 12's default of
# blocking them is left alone: no --allow-scripts here
	(cd ${WRKDIR} && \
		${SETENV} -u MAKEFLAGS -u MFLAGS HOME=${WRKDIR} npm_config_cache=${_NPM_CACHE} \
		npm install --global --no-audit --no-fund --cache ${_NPM_CACHE} \
		--prefer-offline --no-progress --prefix=${_NPM_TREE} \
		@agentclientprotocol/${PORTNAME}@${_NPM_PKGVERSION})
# bundle everything into a single executable with node --build-sea
	${MKDIR} ${_TOOLS}
	${CP} ${FILESDIR}/sea-build.mjs ${_TOOLS}/
	(cd ${_TOOLS} && \
		${SETENV} HOME=${WRKDIR} npm install --no-audit --no-fund \
		--cache ${_NPM_CACHE} --prefer-offline --no-progress esbuild@${_ESBUILD_VER})
# sea-build.mjs injects with process.execPath, so it has to run under the
# interpreter that carries the reserved program header slots
	(cd ${_TOOLS} && \
		${SETENV} HOME=${WRKDIR} CAACP_TREE=${_NPM_TREE}/lib/node_modules \
		CAACP_OUT=${_SEA_OUT} CAACP_CLAUDE=${PREFIX}/bin/claude \
		${LOCALBASE}/bin/${_SEA_NODE} sea-build.mjs)

do-install:
# do not use INSTALL_PROGRAM: stripping rewrites ELF & breaks the SEA blob
	${INSTALL} ${COPY} \
		-m \
		${BINMODE} \
		${_SEA_OUT}/${PORTNAME} \
		${STAGEDIR}${PREFIX}/bin/${PORTNAME}

# Basic functional tests: the executable carries its whole dependency closure,
# it finds Claude Code without being told where it is, the environment still
# overrides that, and it speaks ACP on stdio.

_TEST_BIN=	${STAGEDIR}${PREFIX}/bin/${PORTNAME}
_TEST_INIT=	{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{"fs":{"readTextFile":true,"writeTextFile":true}}}}

do-test:
# no NODE_PATH, no node_modules, no HOME: nothing is read from disk
	${SETENV} -i PATH=${PREFIX}/bin:/usr/bin:/bin ${_TEST_BIN} --version | \
		${GREP} -qx ${DISTVERSION}
# the baked-in ${PREFIX}/bin/claude default resolves, with nothing in the env
	${_TEST_BIN} --cli --version | \
		${GREP} -q "Claude Code"
# and $$CLAUDE_CODE_EXECUTABLE still wins over it
	${SETENV} CLAUDE_CODE_EXECUTABLE=${PREFIX}/bin/claude ${_TEST_BIN} \
		--cli --version | \
		${GREP} -q "Claude Code"
# ACP handshake over stdio; needs neither authentication nor the network
	${PRINTF} '%s\n' '${_TEST_INIT}' | \
		${_TEST_BIN} | \
		${GREP} -q agentCapabilities
	@${ECHO_MSG} "===> ${PORTNAME} functional tests passed"

# maintainer flow:
# bump _CACHE_TAG first: the archive is rebuilt & must not reuse a published name
# make _tarball                     # rebuild the LOCAL distfile & distinfo
# make _upload                      # push it to freefall

_tarball: build-depends
	@if [ -f ${_DISTDIR}/${_NPM_ARCHIVE} ]; then \
		${ECHO_CMD} "===> distfile for _CACHE_TAG=${_CACHE_TAG} already exists;"; \
		${ECHO_CMD} "===> bump _CACHE_TAG before rebuilding it"; \
		exit 1; \
		fi
# we tar up whatever is left lying around, so start the staging area empty
	${RM} -rf ${_NPM_CACHE}
	@${MKDIR} ${WRKDIR} \
		${_NPM_CACHE} \
		${_DISTDIR}
	(cd ${WRKDIR} && \
		${SETENV} HOME=${WRKDIR} npm_config_cache=${_NPM_CACHE} \
		npm install --global --no-audit --no-fund --cache ${_NPM_CACHE} \
		--no-progress --prefix=${WRKDIR}/stage @agentclientprotocol/${PORTNAME}@${_NPM_PKGVERSION} \
		esbuild@${_ESBUILD_VER})
# normally npm only caches tarballs for the host architecture
	(cd ${WRKDIR} && \
		${SETENV} HOME=${WRKDIR} npm cache add --cache ${_NPM_CACHE} \
		@esbuild/freebsd-x64@${_ESBUILD_VER} @esbuild/freebsd-arm64@${_ESBUILD_VER})
	${TAR} -caf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE} _cacache
	${CHMOD} 644 ${_DISTDIR}/${_NPM_ARCHIVE}
	cd ${.CURDIR} && \
		${MAKE} makesum
	@${ECHO_MSG} "===> distinfo updated; run \"make _upload\" to publish"

_upload:
	rsync -Phriv --times --chmod=F644 ${_DISTDIR}/${_NPM_ARCHIVE} freefall.freebsd.org:public_distfiles/${PORTNAME}/

.include <bsd.port.mk>
