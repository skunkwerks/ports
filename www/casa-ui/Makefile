PORTNAME=	casa-ui
DISTVERSION=	0.0.27.0
CATEGORIES=	www sysutils
MASTER_SITES=	LOCAL/dch/casa/:src \
		https://builds.hex.pm/installs/1.20.0/:hex \
		LOCAL/dch/casa/:deps \
		LOCAL/dch/casa/:fluxon
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}:src \
		hex-${_HEX_VER}-otp-${_HEX_OTP}.ez:hex \
		${_DEPS_ARCHIVE}:deps \
		${_FLUXON_ARCHIVE}:fluxon \
		${_ASSETS_ARCHIVE}:fluxon
DIST_SUBDIR=	casa

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Web UI for the casa configuration management cluster
WWW=		https://github.com/dch/casa

LICENSE=	APACHE20 BSD2CLAUSE FLUXON MIT OFL11
LICENSE_COMB=	multi
LICENSE_NAME_FLUXON=	Fluxon UI commercial licence
LICENSE_FILE=	${WRKSRC}/ui/LICENSE.md
LICENSE_PERMS_FLUXON=	no-dist-mirror no-dist-sell no-pkg-mirror no-pkg-sell \
			auto-accept

BUILD_DEPENDS=	${_ERLANG}/bin/erl:lang/erlang-runtime29 \
		${PYTHON_PKGNAMEPREFIX}brotli>0:archivers/py-brotli@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}fonttools>0:print/py-fonttools@${PY_FLAVOR} \
		mix:lang/elixir-devel \
		monaspace>0:x11-fonts/monaspace \
		rebar3:devel/rebar3 \
		rubik>0:x11-fonts/rubik
RUN_DEPENDS=	${LOCALBASE}/libexec/couchdb3/bin/couchdb:databases/couchdb3

USES=		python:build ssl tar:xz
USE_RC_SUBR=	casa_ui

MAKE_ENV=	ERL_LIBS='' \
		GIT_VERSION=${_GIT_REF} \
		HEX_HOME=${WRKDIR}/.hex \
		HEX_OFFLINE=true \
		LANG=C.UTF-8 \
		MIX_ENV=prod \
		MIX_HOME=${WRKDIR}/.mix \
		MIX_PATH=${WRKDIR}/hex-${_HEX_VER}/ebin \
		MIX_REBAR3=${LOCALBASE}/bin/rebar3 \
		PATH=${_ERLANG}/bin:${PATH}

ETCDIR=		${PREFIX}/etc/casa
SUB_FILES=	pkg-message
SUB_LIST=	RELEASE=${_RELEASE}

PLIST_FILES=	"@sample ${ETCDIR}/ui.ucl.sample" \
		bin/casa-ui

# The commit the release is built from. The version is its git describe,
# <tag>-<commits>-g<hash>, as <tag>.<commits>. The repository is
# private, so no site serves the source. _tarball makes an archive of
# ui/ at that commit with git archive, into this host's distfiles cache.
_GIT_HASH=	490b06c
_GIT_REF=	${DISTVERSION:R}-${DISTVERSION:E}-g${_GIT_HASH}

# Where the font ports install, and the characters of a latin subset.
_FONTS=		${LOCALBASE}/share/fonts
_LATIN=		U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2190-2193,U+2212,U+2215,U+FEFF,U+FFFD

_OTP=			29
_ERLANG=		${LOCALBASE}/lib/erlang${_OTP}
_HEX_VER=		2.5.3
_HEX_OTP=		${_OTP}
# The UI's Hex packages, as mix deps.get fetches them for prod, in
# two archives. Fluxon is commercial and its archive is never published:
# it lives in this host's distfiles cache only. It holds Fluxon alone
# and is made the same byte for byte each time, so it changes only when
# _FLUXON_VER does. The built CSS and JavaScript hold Fluxon's theme and
# hooks, so their archive is not published either. It is made anew for
# every version. _tarball makes all three.
_DEPS_ARCHIVE=		${PORTNAME}-deps-${DISTVERSION}.tar.xz
_FLUXON_VER=		3.4.0
_FLUXON_ARCHIVE=	fluxon-${_FLUXON_VER}.tar.xz
_ASSETS_ARCHIVE=	${PORTNAME}-assets-${DISTVERSION}.tar.xz
# The time that every file of the fluxon archive has.
_FLUXON_TIME=		2020-01-01T00:00:00Z

# The UI's directory in the casa tree, ui since the rename after 0.0.9.
_SRC=		ui
_UI=		${WRKSRC}/${_SRC}
_RELEASE=	${PREFIX}/lib/${PORTNAME}

# Both dependency archives unpack to deps/, which belongs in ui/.
# The CSS and JavaScript come built and minified in the assets archive,
# which unpacks to priv/. _tarball builds them.
post-extract:
	${MV} ${WRKDIR}/deps ${_UI}/deps
# heroicons and daisyUI are git dependencies, and the archive has their
# files with no .git, which is 70 MB of history. mix takes them from
# deps/ as they are once they are path dependencies with no lock.
	${REINPLACE_CMD} -E \
		-e 's|github: "tailwindlabs/heroicons",|path: "deps/heroicons",|' \
		-e 's|github: "saadeghi/daisyui",|path: "deps/daisyui",|' \
		-e '/^[[:space:]]*tag: "v[0-9.]+",$$/d' \
		-e '/^[[:space:]]*sparse: "[^"]+",$$/d' \
		-e 's|^([[:space:]]*)compile: false,$$|\1compile: false},|' \
		-e '/^[[:space:]]*depth: 1},$$/d' \
		${_UI}/mix.exs
	${REINPLACE_CMD} -E -e '/^  "(heroicons|daisyui)": \{:git,/d' \
		${_UI}/mix.lock
	${MKDIR} ${_UI}/priv/static/assets/css ${_UI}/priv/static/assets/js
	${CP} ${WRKDIR}/priv/static/assets/css/app.css \
		${_UI}/priv/static/assets/css/app.css
	${CP} ${WRKDIR}/priv/static/assets/js/app.js \
		${_UI}/priv/static/assets/js/app.js

# The two fonts the UI serves, made here as latin subsets of the files
# of the font ports. The fonts are needed to build and not to run: the
# package has the subsets, and a browser that has the fonts uses its
# own.
pre-build:
	${MKDIR} ${_UI}/priv/static/fonts
	${PYTHON_CMD} -m fontTools.subset \
		"${_FONTS}/Rubik/Rubik[wght].ttf" \
		--unicodes=${_LATIN} --layout-features='*' --flavor=woff2 \
		--output-file=${_UI}/priv/static/fonts/rubik-var-latin.woff2
	${PYTHON_CMD} -m fontTools.subset \
		"${_FONTS}/monaspace/Monaspace Argon Var.ttf" \
		--unicodes=${_LATIN} --layout-features='*' --flavor=woff2 \
		--output-file=${_UI}/priv/static/fonts/monaspace-argon-var-latin.woff2

# phx.digest only copies and hashes the built CSS and JavaScript, so
# neither esbuild nor tailwind runs here.
do-build:
	(cd ${_UI} && ${SETENV} ${MAKE_ENV} ${LOCALBASE}/bin/mix do \
		deps.compile + compile + phx.digest + release casa_ui)

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/lib
	${CP} -a ${_UI}/_build/prod/rel/casa_ui ${STAGEDIR}${_RELEASE}
	${RM} ${STAGEDIR}${_RELEASE}/bin/casa_ui.bat \
		${STAGEDIR}${_RELEASE}/releases/*/*.bat
	${FIND} ${STAGEDIR}${_RELEASE} -type f \( -name '*.so' -o -perm -u+x \) | \
		${XARGS} ${FILE} | ${GREP} ELF | ${CUT} -d: -f1 | \
		${XARGS} ${STRIP_CMD}
	${PRINTF} '#!/bin/sh\nexec %s/bin/casa_ui "$$@"\n' ${_RELEASE} \
		> ${WRKDIR}/${PORTNAME}
	${INSTALL_SCRIPT} ${WRKDIR}/${PORTNAME} ${STAGEDIR}${PREFIX}/bin
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${FILESDIR}/ui.ucl.sample ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${_UI}/LICENSE.md ${STAGEDIR}${_RELEASE}

# the release's files, with their application versions, go in the plist
# here rather than by hand
post-install:
	@cd ${STAGEDIR}${PREFIX} && \
		${FIND} lib/${PORTNAME} -type f -o -type l | \
		${SORT} >> ${TMPPLIST}

# Maintainer targets, run from the port's place in the casa tree:
#
#   make _tarball	the source archive, the two dependency archives
#			and the archive of the built CSS and JavaScript
#			for _GIT_HASH, then makesum. It needs the network,
#			the fluxon Hex repository set up, ui/README.md, and
#			devel/esbuild and www/tailwindcss4 on this host.
#   make _upload	publish the deps archive. The source, the fluxon
#			and the assets archives stay in this host's
#			distfiles cache, where poudriere reads them.
_CASA_TREE?=	${.CURDIR}/../../../..
_VENDOR=	${WRKDIR}/vendor

_tarball:
	@if [ -f ${_DISTDIR}/${_DEPS_ARCHIVE} ]; then \
		${ECHO_CMD} "===> ${_DEPS_ARCHIVE} exists already;"; \
		${ECHO_CMD} "===> remove it or bump DISTVERSION first"; \
		exit 1; \
	fi
	${RM} -r ${_VENDOR}
	${MKDIR} ${_VENDOR} ${_DISTDIR}
	git -C ${_CASA_TREE} archive --format=tar --prefix=${DISTNAME}/ \
		${_GIT_HASH} ${_SRC} | ${XZ_CMD} > ${_DISTDIR}/${DISTNAME}${EXTRACT_SUFX}
	${CHMOD} 644 ${_DISTDIR}/${DISTNAME}${EXTRACT_SUFX}
	git -C ${_CASA_TREE} archive ${_GIT_HASH} ${_SRC} | ${TAR} -xf - -C ${_VENDOR}
	(cd ${_VENDOR}/${_SRC} && ${SETENV} MIX_ENV=prod PATH=${_ERLANG}/bin:${PATH} \
		${LOCALBASE}/bin/mix deps.get --only prod)
	@if [ ! -d ${_VENDOR}/${_SRC}/deps/fluxon ] || \
	    ! ${GREP} -q '"${_FLUXON_VER}"' ${_VENDOR}/${_SRC}/deps/fluxon/hex_metadata.config; then \
		${ECHO_CMD} "===> deps/fluxon is not ${_FLUXON_VER}, set _FLUXON_VER"; \
		exit 1; \
	fi
# the CSS and JavaScript, minified with this host's tailwindcss and esbuild
	(cd ${_VENDOR}/${_SRC} && ${SETENV} MIX_ENV=prod PATH=${_ERLANG}/bin:${PATH} \
		${LOCALBASE}/bin/mix do compile + tailwind casa_ui --minify + \
		esbuild casa_ui --minify)
	${TAR} -cJf ${_DISTDIR}/${_DEPS_ARCHIVE} -C ${_VENDOR}/${_SRC} \
		--exclude 'deps/*/.git' \
		--exclude deps/fluxon --uname root --gname wheel deps
# Fluxon alone, with its files in one order, one time, one owner and
# modes that no umask changes, so that the archive is the same each run.
	${CHMOD} -R u=rwX,go=rX ${_VENDOR}/${_SRC}/deps/fluxon
	${FIND} ${_VENDOR}/${_SRC}/deps/fluxon -exec \
		${TOUCH} -h -d ${_FLUXON_TIME} {} +
	(cd ${_VENDOR}/${_SRC} && ${FIND} deps/fluxon -print | \
		${SETENV} LC_ALL=C ${SORT} > ${_VENDOR}/fluxon.list)
	${TAR} -cJf ${_DISTDIR}/${_FLUXON_ARCHIVE} -C ${_VENDOR}/${_SRC} \
		--no-recursion --uid 0 --gid 0 --uname root --gname wheel \
		-T ${_VENDOR}/fluxon.list
	${TAR} -cJf ${_DISTDIR}/${_ASSETS_ARCHIVE} -C ${_VENDOR}/${_SRC} \
		--uname root --gname wheel \
		priv/static/assets/css/app.css priv/static/assets/js/app.js
	${CHMOD} 644 ${_DISTDIR}/${_DEPS_ARCHIVE} ${_DISTDIR}/${_FLUXON_ARCHIVE} \
		${_DISTDIR}/${_ASSETS_ARCHIVE}
	cd ${.CURDIR} && ${MAKE} makesum
	@${ECHO_MSG} "===> distinfo updated; run \"make _upload\" to publish"

_upload:
	rsync -Phriv --times --chmod=F644 ${_DISTDIR}/${_DEPS_ARCHIVE} \
		freefall.freebsd.org:public_distfiles/casa/

.include <bsd.port.mk>
