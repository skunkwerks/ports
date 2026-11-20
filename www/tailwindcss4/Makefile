PORTNAME=	tailwindcss4
DISTVERSION=	4.3.3
PORTREVISION=	7
CATEGORIES=	www devel
MASTER_SITES=	LOCAL/dch/${PORTNAME}/:npm \
		https://codeload.github.com/tailwindlabs/tailwindcss/tar.gz/v${DISTVERSION}?dummy=/:twsrc \
		LOCAL/dch/${PORTNAME}/:twsrc \
		https://codeload.github.com/parcel-bundler/lightningcss/tar.gz/v${_LCSS_VER}?dummy=/:lcsssrc \
		LOCAL/dch/${PORTNAME}/:lcsssrc \
		LOCAL/dch/${PORTNAME}/:cargo
DISTFILES=	${_NPM_ARCHIVE}:npm
DIST_SUBDIR=	${PORTNAME}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Utility-first CSS framework, as a single executable
WWW=		https://tailwindcss.com/

LICENSE=	MIT

ONLY_FOR_ARCHS=	aarch64 amd64 powerpc64 powerpc64le # internal .node libraries not supported elsewhere

# The final package is a PIE node26 binary with a customised archive that
# contains the original JavaScript appended to it. A few stray shared
# objects and other files are still required locally.
BUILD_DEPENDS=	${_SEA_NODE}:www/node${_NODE_VERSION}-sea \
		npm:www/npm-node${_NODE_VERSION}
# sync with the NodeJS dependencies: the executable is a copy of the
# node26-sea interpreter, so it needs everything that one links against
LIB_DEPENDS=	libada.so:devel/libada \
		libbrotlidec.so:archivers/brotli \
		libcares.so:dns/c-ares \
		libffi.so:devel/libffi \
		libhdr_histogram.so:graphics/hdr_histogram \
		libicui18n.so:devel/icu \
		libllhttp.so:www/llhttp \
		libnbytes.so:www/nbytes \
		libnghttp2.so:www/libnghttp2 \
		libnghttp3.so:www/libnghttp3 \
		libngtcp2.so:net/libngtcp2 \
		libsimdjson.so:devel/simdjson \
		libsqlite3.so:databases/sqlite3 \
		libuv.so:devel/libuv \
		libuvwasi.so:devel/uvwasi \
		libzstd.so:archivers/zstd
USES=		nodejs:${_NODE_VERSION},build python:build ssl tar:txz

CONFLICTS_INSTALL=	tailwindcss*

_ESBUILD_VER=	0.28.2
_LCSS_VER=	1.32.0
_NODE_ARCH=	${ARCH:S/aarch64/arm64/:C/powerpc64.*/ppc64/}
_NODE_VERSION=	26
# the interpreter that injects the blob, and that the executable is a copy of
_SEA_NODE=	node${_NODE_VERSION}-sea
_TAILWIND_VER=	${DISTVERSION}
_WATCHER_VER=	2.5.1

_CACHE_TAG=	202609172020
_NPM_CACHE=	${WRKDIR}/cache
_NPM_ARCHIVE=	${PORTNAME}-npm-cache-${DISTVERSION}-${_CACHE_TAG}${EXTRACT_SUFX}
_CARGO_ARCHIVE=	${PORTNAME}-cargo-vendor-${DISTVERSION}-${_CACHE_TAG}${EXTRACT_SUFX}
_NPM_TREE=	${WRKDIR}/npmtree
_TW_MODULES=	${_NPM_TREE}/lib/node_modules/@tailwindcss/cli/node_modules
_WATCHER_PKG=	${_NPM_TREE}/lib/node_modules/@parcel/watcher
_TOOLS=		${WRKDIR}/tools
_SEA_OUT=	${WRKDIR}/sea
_SEA_ASSETS=	lib/${PORTNAME}
_TAILWIND_SRC=	${WRKDIR}/tailwindcss-${DISTVERSION}
_LCSS_SRC=	${WRKDIR}/lightningcss-${_LCSS_VER}
_CARGO_VENDOR=	${WRKDIR}/cargo-vendor

.include <bsd.port.pre.mk>

# oxide & lightningcss need to be built from source crates on all but amd64
DISTFILES+=	tailwindcss-v${DISTVERSION}.tar.gz:twsrc \
		lightningcss-v${_LCSS_VER}.tar.gz:lcsssrc \
		${_CARGO_ARCHIVE}:cargo
BUILD_DEPENDS+=	rust>0:lang/rust

do-extract:
	@${MKDIR} ${_NPM_CACHE}
	${TAR} -xf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE}
.if ${ARCH} != amd64
	${TAR} -xf ${_DISTDIR}/tailwindcss-v${DISTVERSION}.tar.gz -C ${WRKDIR}
	${TAR} -xf ${_DISTDIR}/lightningcss-v${_LCSS_VER}.tar.gz -C ${WRKDIR}
	${MKDIR} ${_CARGO_VENDOR}
	${TAR} -xf ${_DISTDIR}/${_CARGO_ARCHIVE} -C ${_CARGO_VENDOR}
.endif

do-build:
# because nodejs is fiddly we can't build & then install
	${ECHO_CMD} offline=true > ${WRKDIR}/.npmrc
# npm's self-update check ignores offline=true; keep the build off the network
	${ECHO_CMD} update-notifier=false >> ${WRKDIR}/.npmrc
	${ECHO_CMD} python=${PYTHON_CMD} >> ${WRKDIR}/.npmrc
.if ${ARCH} != amd64
# configure cargo for offline vendored build
	${MKDIR} ${WRKDIR}/.cargo
	${PRINTF} '[source.crates-io]\nreplace-with = "vendor"\n[source.vendor]\ndirectory = "%s"\n' \
		${_CARGO_VENDOR} > ${WRKDIR}/.cargo/config.toml
# build tailwind-oxide Rust NAPI module for freebsd-${_NODE_ARCH}
	(cd ${_TAILWIND_SRC} && \
		${SETENV} CARGO_HOME=${WRKDIR}/.cargo CARGO_NET_OFFLINE=true \
		cargo build --release -p tailwind-oxide && \
		${CP} target/release/libtailwind_oxide.so crates/node/tailwindcss-oxide.freebsd-${_NODE_ARCH}.node)
# build lightningcss Rust NAPI module for freebsd-${_NODE_ARCH}
	(cd ${_LCSS_SRC} && \
		${SETENV} CARGO_HOME=${WRKDIR}/.cargo CARGO_NET_OFFLINE=true \
		cargo build --release -p lightningcss_node)
.endif

# scrub MAKEFLAGS/MFLAGS as it breaks node-gyp & gmake
# npm 12 breaks a lot of things
# - blocks dependency install scripts which skips .node builds
# - rejects --build-from-source as an unknown flag
# - @parcel/watcher reads npm_config_build_from_source from env
	(cd ${WRKDIR} && \
		${SETENV} -u MAKEFLAGS -u MFLAGS \
		HOME=${WRKDIR} npm_config_cache=${_NPM_CACHE} \
		npm_config_build_from_source=true \
		npm_config_devdir=${_NPM_CACHE} npm_config_nodedir=${PREFIX} \
		npm_config_node_gyp_include_dir=${PREFIX}/include/node \
		npm install --global --no-audit --no-fund --cache \
		${_NPM_CACHE} --prefer-offline --verbose --no-progress \
		--allow-scripts=@parcel/watcher \
		--prefix=${_NPM_TREE} @parcel/watcher@${_WATCHER_VER} \
		@tailwindcss/cli@${_TAILWIND_VER})
.if ${ARCH} != amd64
# drop x86 binaries in favour of our source-built ones. sea-build.mjs finds each
# addon by globbing its directory, so the package.json shims are not needed
	${RM} -rf ${_TW_MODULES}/@tailwindcss/oxide-freebsd-x64 ${_TW_MODULES}/lightningcss-freebsd-x64 \
		${_WATCHER_PKG}/node_modules/@parcel/watcher-freebsd-x64
	${MKDIR} ${_TW_MODULES}/@tailwindcss/oxide-freebsd-${_NODE_ARCH}
	${INSTALL_DATA} ${_TAILWIND_SRC}/crates/node/tailwindcss-oxide.freebsd-${_NODE_ARCH}.node \
		${_TW_MODULES}/@tailwindcss/oxide-freebsd-${_NODE_ARCH}/
	${MKDIR} ${_TW_MODULES}/lightningcss-freebsd-${_NODE_ARCH}
	${INSTALL_DATA} ${_LCSS_SRC}/target/release/liblightningcss_node.so \
		${_TW_MODULES}/lightningcss-freebsd-${_NODE_ARCH}/lightningcss.freebsd-${_NODE_ARCH}.node
# the x86 shims we replaced shipped a LICENSE, keep one alongside ours. oxide &
# lightningcss come from the source trees we built, watcher from its own package
	${INSTALL_DATA} ${_TAILWIND_SRC}/LICENSE \
		${_TW_MODULES}/@tailwindcss/oxide-freebsd-${_NODE_ARCH}/
	${INSTALL_DATA} ${_LCSS_SRC}/LICENSE \
		${_TW_MODULES}/lightningcss-freebsd-${_NODE_ARCH}/
.endif
# strip .node files; they are shared libraries, path varies between architectures
	${FIND} ${_NPM_TREE} -name "*.node" -exec ${STRIP_CMD} {} +
# bundle everything into a single executable with node --build-sea
	${MKDIR} ${_TOOLS}
	${CP} ${FILESDIR}/sea-build.mjs ${FILESDIR}/sea-launcher.mjs \
		${_TOOLS}/
	(cd ${_TOOLS} && \
		${SETENV} HOME=${WRKDIR} npm install --no-audit --no-fund \
		--cache ${_NPM_CACHE} --prefer-offline --no-progress esbuild@${_ESBUILD_VER})
# sea-build.mjs injects with process.execPath, so it has to run under the
# interpreter that carries the reserved program header slots
	(cd ${_TOOLS} && \
		${SETENV} HOME=${WRKDIR} TWSEA_TREE=${_NPM_TREE}/lib/node_modules \
		TWSEA_OUT=${_SEA_OUT} TWSEA_SYSTEM_DIR=${PREFIX}/${_SEA_ASSETS} \
		${LOCALBASE}/bin/${_SEA_NODE} sea-build.mjs)

do-install:
# do not use INSTALL_PROGRAM: stripping rewrites ELF & breaks the SEA blob
	${INSTALL} ${COPY} \
		-m \
		${BINMODE} \
		${_SEA_OUT}/tailwindcss \
		${STAGEDIR}${PREFIX}/bin/tailwindcss
	${LN} -sf tailwindcss ${STAGEDIR}${PREFIX}/bin/tailwind
# runtime assets: native addons + the tailwindcss package. the launcher baked
# into the executable reads them from there (TWSEA_SYSTEM_DIR above); they are
# not embedded in the executable, so it needs them present
	${MKDIR} ${STAGEDIR}${PREFIX}/${_SEA_ASSETS}
	(cd ${_SEA_OUT}/assets && \
		${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/${_SEA_ASSETS})

# bundled tailwindcss has content-hashed dist/ chunk names per release
post-install:
	@${FIND} -s \
		${STAGEDIR}${PREFIX}/${_SEA_ASSETS}/node_modules \
		-not \
		-type \
		d | \
		${SED} -e 's|^${STAGEDIR}${PREFIX}/||' \
		>> \
		${TMPPLIST}

# Basic functional tests:
# oxide scanner, variant engine, lightningcss minification, TypeScript
# plugin loading (jiti + babel + the shipped tailwindcss JS API), & Phoenix.
# the two package-resolved plugins are withOptions plugins taking an options
# block, as daisyUI is used from a real app.css, and they require/import
# tailwindcss/plugin from where they live rather than from the CLI

_TEST_DIR=	${WRKDIR}/twtest

do-test:
	${RM} -r ${_TEST_DIR}
	${MKDIR} ${_TEST_DIR} \
		${_TEST_DIR}/deps/daisyui/packages/bundle \
		${_TEST_DIR}/vendor
	${PRINTF} '@import "tailwindcss";\n@plugin "./plug.ts";\n@plugin "daisyui/packages/bundle/daisyui" {\n  zoom: 3;\n}\n@plugin "daisyui/packages/bundle/daisyui-theme" {\n  zoom: 4;\n}\n@plugin "./vendor/fake";\n@plugin "./vendor/bundle.js" {\n  zoom: 6;\n}\n' \
		> ${_TEST_DIR}/input.css
	${PRINTF} 'import plugin from "tailwindcss/plugin";\nexport default plugin(({ addUtilities }: any) => addUtilities({ ".zz": { zoom: "2" } }));\n' \
		> ${_TEST_DIR}/plug.ts
	${PRINTF} 'const plugin = require("tailwindcss/plugin");\nmodule.exports = plugin.withOptions((o = {}) => ({ addUtilities }) => addUtilities({ ".phx-cjs": { zoom: String(o.zoom) } }));\n' \
		> ${_TEST_DIR}/deps/daisyui/packages/bundle/daisyui.js
	${PRINTF} 'import plugin from "tailwindcss/plugin";\nexport default plugin.withOptions((o = {}) => ({ addUtilities }) => addUtilities({ ".phx-esm": { zoom: String(o.zoom) } }));\n' \
		> ${_TEST_DIR}/deps/daisyui/packages/bundle/daisyui-theme.mjs
	${PRINTF} 'export default { handler: ({ addUtilities }) => addUtilities({ ".phx-vnd": { zoom: "5" } }) };\n' \
		> ${_TEST_DIR}/vendor/fake.mjs
# esbuild emits CJS bundles as {__esModule:true,default:...}; daisyUI ships one
	${PRINTF} 'const plugin = require("tailwindcss/plugin");\nmodule.exports = { __esModule: true, default: plugin.withOptions((o = {}) => ({ addUtilities }) => addUtilities({ ".phx-cjsb": { zoom: String(o.zoom) } })) };\n' \
		> ${_TEST_DIR}/vendor/bundle.js
	${PRINTF} '<div class="flex zz underline md:grid-cols-2 hover:bg-red-500/50 phx-cjs phx-esm phx-vnd phx-cjsb">x</div>\n' \
		> ${_TEST_DIR}/index.html
	${PRINTF} '@import "tailwindcss";\n' > ${_TEST_DIR}/bare.css
# minified output
	(cd ${_TEST_DIR} && \
		${SETENV} TAILWINDCSS_SEA_ASSETS=${STAGEDIR}${PREFIX}/${_SEA_ASSETS} \
		NODE_PATH=${_TEST_DIR}/deps ${STAGEDIR}${PREFIX}/bin/tailwindcss \
		-i input.css -o out.css --minify)
	${GREP} -q 'zoom:2' ${_TEST_DIR}/out.css
	${GREP} -q 'zoom:3' ${_TEST_DIR}/out.css
	${GREP} -q 'zoom:4' ${_TEST_DIR}/out.css
	${GREP} -q 'zoom:5' ${_TEST_DIR}/out.css
	${GREP} -q 'zoom:6' ${_TEST_DIR}/out.css
	${GREP} -q 'grid-cols-2' ${_TEST_DIR}/out.css
	${GREP} -q 'bg-red-500' ${_TEST_DIR}/out.css
# same again, unminified
	(cd ${_TEST_DIR} && \
		${SETENV} TAILWINDCSS_SEA_ASSETS=${STAGEDIR}${PREFIX}/${_SEA_ASSETS} \
		NODE_PATH=${_TEST_DIR}/deps ${STAGEDIR}${PREFIX}/bin/tailwindcss \
		-i input.css -o plain.css)
	${GREP} -q 'zoom: 2' ${_TEST_DIR}/plain.css
# canonicalize round-trips without touching the filesystem
	${SETENV} TAILWINDCSS_SEA_ASSETS=${STAGEDIR}${PREFIX}/${_SEA_ASSETS} \
		${STAGEDIR}${PREFIX}/bin/tailwind canonicalize flex | \
		${GREP} -qx flex
# test @import "tailwindcss" from a tree with no node_modules, and no NODE_PATH;
# sea-launcher.mjs points NODE_PATH at the node_modules in the SEA assets
	(cd ${_TEST_DIR} && ${SETENV} -u NODE_PATH \
		TAILWINDCSS_SEA_ASSETS=${STAGEDIR}${PREFIX}/${_SEA_ASSETS} \
		${STAGEDIR}${PREFIX}/bin/tailwindcss -i bare.css -o bare.out.css)
	${GREP} -q 'grid-cols-2' ${_TEST_DIR}/bare.out.css
# -webkit-text-size-adjust only appears if the base layer of the resolved
# tailwindcss/index.css was emitted, ie the @import really was satisfied
	${GREP} -q 'text-size-adjust' ${_TEST_DIR}/bare.out.css
	@${ECHO_MSG} "===> tailwindcss functional tests passed"

# maintainer flow is now architecture independent
# bump _CACHE_TAG first: archives are rebuilt & must not reuse a published name
# make _tarball                     # rebuild both LOCAL distfiles & distinfo
# make _upload                      # push them to freefall

# merge crates from tailwindcss & lightningcss repos before packaging
_SRC_DISTFILES=	tailwindcss-v${DISTVERSION}.tar.gz:twsrc \
		lightningcss-v${_LCSS_VER}.tar.gz:lcsssrc

_tarball: build-depends
	@if [ -f ${_DISTDIR}/${_NPM_ARCHIVE} -o -f ${_DISTDIR}/${_CARGO_ARCHIVE} ]; then \
		${ECHO_CMD} "===> distfiles for _CACHE_TAG=${_CACHE_TAG} already exist;"; \
		${ECHO_CMD} "===> bump _CACHE_TAG before rebuilding them"; \
		exit 1; \
		fi
# we tar up whatever is left lying around, so start both staging areas empty
	${RM} -rf ${_NPM_CACHE} ${WRKDIR}/vendor-stage
	@${MKDIR} ${WRKDIR} \
		${_NPM_CACHE} \
		${_DISTDIR}
	${ECHO_CMD} python=${PYTHON_CMD} > ${WRKDIR}/.npmrc
	(cd ${WRKDIR} && \
		${SETENV} HOME=${WRKDIR} npm_config_cache=${_NPM_CACHE} \
		npm_config_devdir=${_NPM_CACHE} npm_config_nodedir=${PREFIX} \
		npm_config_node_gyp_include_dir=${PREFIX}/include/node \
		npm install --global --no-audit --no-fund --cache \
		${_NPM_CACHE} --verbose --no-progress --prefix=${WRKDIR}/stage \
		@parcel/watcher@${_WATCHER_VER} @tailwindcss/cli@${_TAILWIND_VER} \
		esbuild@${_ESBUILD_VER})

# normally npm only caches tarballs for the host architecture
	(cd ${WRKDIR} && \
		${SETENV} HOME=${WRKDIR} npm cache add --cache ${_NPM_CACHE} \
		@tailwindcss/oxide-freebsd-x64@${_TAILWIND_VER} lightningcss-freebsd-x64@${_LCSS_VER} \
		@parcel/watcher-freebsd-x64@${_WATCHER_VER} @esbuild/freebsd-x64@${_ESBUILD_VER} \
		@esbuild/freebsd-arm64@${_ESBUILD_VER})
	${TAR} -caf ${_DISTDIR}/${_NPM_ARCHIVE} -C ${_NPM_CACHE} _cacache
	${CHMOD} 644 ${_DISTDIR}/${_NPM_ARCHIVE}
# cargo crates, merged from both repos
	cd ${.CURDIR} && \
		${MAKE} fetch DISTFILES="${_SRC_DISTFILES}" NO_CHECKSUM=yes
	${TAR} -xf ${_DISTDIR}/tailwindcss-v${DISTVERSION}.tar.gz -C ${WRKDIR}
	${TAR} -xf ${_DISTDIR}/lightningcss-v${_LCSS_VER}.tar.gz -C ${WRKDIR}
	${MKDIR} ${WRKDIR}/vendor-stage
# --versioned-dirs to avoid clobbering variants, --no-delete to merge the two
	(cd ${_TAILWIND_SRC} && \
		cargo vendor --versioned-dirs --no-delete ${WRKDIR}/vendor-stage)
	(cd ${_LCSS_SRC} && \
		cargo vendor --versioned-dirs --no-delete ${WRKDIR}/vendor-stage)
	${TAR} -caf ${_DISTDIR}/${_CARGO_ARCHIVE} -C ${WRKDIR}/vendor-stage \
		.
	${CHMOD} 644 ${_DISTDIR}/${_CARGO_ARCHIVE}
	cd ${.CURDIR} && \
		${MAKE} makesum
	@${ECHO_MSG} "===> distinfo updated; run \"make _upload\" to publish"

_upload:
	rsync -Phriv --times --chmod=F644 ${_DISTDIR}/${_NPM_ARCHIVE} ${_DISTDIR}/${_CARGO_ARCHIVE} \
		freefall.freebsd.org:public_distfiles/${PORTNAME}/

.include <bsd.port.post.mk>
