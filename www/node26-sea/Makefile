PORTNAME=	node
PORTVERSION=	${NODEJS_PORTVERSION}
DISTVERSIONPREFIX=	v
CATEGORIES=	www
MASTER_SITES=	https://nodejs.org/dist/v${PORTVERSION}/
PKGNAMESUFFIX=	${PORTVERSION:R:R}-sea

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Node.js interpreter that builds single executable apps without LIEF
WWW=		https://nodejs.org/ \
		https://github.com/nodejs/node

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BROKEN_SSL=	libressl libressl-devel
BROKEN_SSL_REASON=	Node.js ${PORTVERSION:R:R}.x requires OpenSSL or the BUNDLED_SSL option enabled
ONLY_FOR_ARCHS=	aarch64 amd64 armv6 armv7 i386 powerpc64 powerpc64le

# googletest only provides the header-only gtest_prod.h to the node binary;
# the gtest libraries are linked by the cctest target alone
BUILD_DEPENDS=	googletest>0:devel/googletest \
		objdump:devel/binutils
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
USES=		compiler:c++20-lang gmake localbase pkgconfig python:build shebangfix tar:xz

# The installed interpreter, named so that it can sit beside www/node26
SEA_NODE=	${PORTNAME}${PKGNAMESUFFIX}
PLIST_FILES=	bin/${SEA_NODE}

# merve stays bundled: devel/merve links the system libsimdutf, while node
# bundles and exports its own simdutf. rtld binds libsimdutf's internal calls
# to node's copy, the dispatch tables disagree, and CJS export lexing jumps
# to garbage (SIGBUS). Revisit together with --shared-simdutf.
CONFIGURE_ARGS=	--prefix=${PREFIX:S|^${DESTDIR}||} \
		--shared-ada \
		--shared-brotli \
		--shared-cares \
		--shared-ffi \
		--shared-gtest \
		--shared-hdr-histogram \
		--shared-http-parser \
		--shared-libuv \
		--shared-nbytes \
		--shared-nghttp2 \
		--shared-nghttp3 \
		--shared-ngtcp2 \
		--shared-simdjson \
		--shared-sqlite \
		--shared-uvwasi \
		--shared-uvwasi-includes=${LOCALBASE}/include \
		--shared-zlib \
		--shared-zstd \
		--with-intl=system-icu \
		--without-npm
CXXFLAGS_powerpc64=	-mpower8-vector
HAS_CONFIGURE=	yes
MAKE_ENV=	CC.host="${CCACHE_BIN} ${CC}" \
		CFLAGS.host="${CFLAGS}" \
		CXX.host="${CCACHE_BIN} ${CXX}" \
		CXXFLAGS.host="${CXXFLAGS}" \
		LDFLAGS.host="${LDFLAGS}" \
		LINK.host="${CXX}"
REINPLACE_ARGS=	-i ''


SHEBANG_FILES=	deps/v8/third_party/inspector_protocol/*.py \
		deps/v8/tools/*.py \
		tools/*.py \
		tools/inspector_protocol/*.py

OPTIONS_DEFINE=	BUNDLED_SSL DOCS JIT
OPTIONS_DEFAULT=JIT
OPTIONS_SUB=	yes
BUNDLED_SSL_DESC=	Use bundled OpenSSL implementation from node.js
JIT_DESC=		Use Just In Time compiler

BUNDLED_SSL_CONFIGURE_OFF=	--openssl-use-def-ca-store --shared-openssl
BUNDLED_SSL_USES_OFF=	ssl
JIT_CONFIGURE_OFF=	--v8-lite-mode

.include "Makefile.version"
.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MBUNDLED_SSL} && ${ARCH} != amd64
CONFIGURE_ARGS+=--openssl-no-asm
.endif

# Single executable applications (node --build-sea) are built without LIEF:
# files/patch-src_node__sea__bin.cc replaces the LIEF ELF injector with a
# native one that only appends the blob and fills program header slots which
# files/sea-pad.ld reserves at link time. That keeps the program header table
# in the first page, where FreeBSD's image activator requires it
# (__elfN(phdr_in_zero_page), sys/kern/imgact_elf.c), and drops the dependency
# on devel/lief and, through it, on security/mbedtls4.
CONFIGURE_ARGS+=--without-lief

# The injector writes 64-bit little-endian ELF only; elsewhere --build-sea
# reports that the format is unsupported instead of producing a broken file.
.if ${ARCH} == aarch64 || ${ARCH} == amd64
SEA_SUPPORTED=	yes
# Keep the executable position independent; the blob is mapped by a new
# PT_LOAD placed above every existing segment.
CFLAGS+=	-fPIE
LDFLAGS+=	-pie
.endif

post-patch:
	@${REINPLACE_CMD} -e 's|/usr/local|${LOCALBASE}|' ${WRKSRC}/tools/v8_gypfiles/v8.gyp
# The linker script that reserves the program header slots is referenced by an
# absolute path: gyp passes ldflags through verbatim, and the link runs from
# the build directory rather than from ${WRKSRC}.
	@${CP} ${FILESDIR}/sea-pad.ld ${WRKSRC}/sea-pad.ld
	@${REINPLACE_CMD} -e 's|%%SEA_PAD_LD%%|${WRKSRC}/sea-pad.ld|' ${WRKSRC}/node.gyp
# Clean up bundled libraries
	@${RM} -r ${WRKSRC}/deps/ada/
	@${RM} -r ${WRKSRC}/deps/brotli/
	@${RM} -r ${WRKSRC}/deps/cares/
	@${RM} -r ${WRKSRC}/deps/googletest/
	@${RM} -r ${WRKSRC}/deps/histogram/
	@${RM} -r ${WRKSRC}/deps/icu-small/
	@${RM} -r ${WRKSRC}/deps/LIEF/
	@${RM} -r ${WRKSRC}/deps/llhttp/
	@${RM} -r ${WRKSRC}/deps/nbytes/
	@${RM} -r ${WRKSRC}/deps/nghttp2/
	@${RM} -r ${WRKSRC}/deps/ngtcp2/
	@${RM} -r ${WRKSRC}/deps/npm/
	@${RM} -r ${WRKSRC}/deps/simdjson/
	@${RM} -r ${WRKSRC}/deps/sqlite/
	@${RM} -r ${WRKSRC}/deps/uv/
	@${RM} -r ${WRKSRC}/deps/uvwasi/
	@${RM} -r ${WRKSRC}/deps/zlib/
	@${RM} -r ${WRKSRC}/deps/zstd/

post-configure:
	# Post-process Makefile and *.mk files created by node-gyp and remove
	# all occurrences of -I${LOCALBASE}/include. C*FLAGS include this
	# before all -I../deps/* for bundled code. This can cause build
	# breakages if the dependency is installed in ${LOCALBASE}. The
	# USES+=localbase above will ensure that we pick up includes for real
	# external dependencies.
	@${FIND} ${WRKSRC}/out -type f -print0 | ${XARGS} -0 ${REINPLACE_CMD} -e 's|-I${LOCALBASE}/include||g'

# Only the interpreter is installed, under its own name: this port is a build
# tool for producing single executable applications, not a replacement for
# www/node26. Headers, documentation and node_modules would collide with it,
# and everything that needs a general purpose node keeps using www/node26.
do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/out/Release/node \
		${STAGEDIR}${PREFIX}/bin/${SEA_NODE}

post-install:
# Fail if two simdutf copies end up in one process (node exports its bundled
# simdutf; a DSO linking the system libsimdutf.so, e.g. libmerve, then binds
# to the wrong one and CJS export lexing SIGBUSes). Importing a CommonJS
# module from ESM runs that lexer; stdin avoids a temp file.
	${ECHO_CMD} 'exports.ok = 1' | ${STAGEDIR}${PREFIX}/bin/${SEA_NODE} --input-type=module -e 'import "/dev/stdin"'

# Exercise the native injector end to end: build a real single executable
# application with the staged node, run it, and check that the result is still
# a well formed FreeBSD executable. Node's own SEA tests cannot cover this;
# they skip whenever node is built without LIEF or against a system ICU and
# OpenSSL, which is exactly how this port builds.
.if defined(SEA_SUPPORTED)
do-test: stage
	@${SETENV} NODE=${STAGEDIR}${PREFIX}/bin/${SEA_NODE} READELF=${READELF} \
		${SH} ${FILESDIR}/sea-selftest.sh ${WRKDIR}/sea-selftest
.else
do-test:
	@${ECHO_MSG} "===> Skipping the SEA self test: ${ARCH} is not a 64-bit little-endian ELF platform"
.endif

.include <bsd.port.mk>
