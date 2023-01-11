PORTNAME=	tailwindcss
DISTVERSIONPREFIX=	v
DISTVERSION=	3.2.4
CATEGORIES=	www devel

MASTER_SITES+=	LOCAL/dch/tailwindcss/:cache
#		https://nodejs.org/dist/v${NODE_VERSION_PKGFETCH}/:nodejs
DISTFILES+=	${CACHE_TXZ}:cache \
		${PACKAGE_TXZ}:cache
#		node-v${NODE_VERSION_PKGFETCH}.tar.gz:nodejs
# v8-8.9.255.25_all.tar.gz

MAINTAINER=	dch@FreeBSD.org
COMMENT=	CLI for building and compiling Tailwind UI CSS and templates
WWW=		https://tailwindui.com/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BROKEN_SSL=	libressl libressl-devel
BROKEN_SSL_REASON=	Embedded Node.js requires BUNDLED_SSL option
BROKEN_aarch64=	more nodejs patches needed
ONLY_FOR_ARCHS=	aarch64 amd64
ONLY_FOR_ARCHS_REASON=	not yet ported to anything else

USES=		compiler:gcc-c++11-lib gmake localbase pkgconfig python:build nodejs:build,lts ninja
USE_GITHUB=	yes
GH_ACCOUNT=	tailwindlabs

PORTDOCS=	README.md

PLIST_FILES=	bin/tailwind

OPTIONS_DEFINE=	DOCS

CONFIGURE=	--fully-static --without-npm --openssl-no-asm

#PREFIX_RELDEST=	${PREFIX:S,^${DESTDIR},,}
#REINPLACE_ARGS=	-i ''
MAKE_ENV+= \
		NPM_CONFIG_CACHE=${CACHE_DIR} \
		NPM_OFFLINE=1 \
		PKG_CACHE_PATH=${CACHE_DIR} \
		PATH="${WRKSRC}/node_modules/.bin:${PATH}" \
		PYTHONDONTWRITEBYTECODE=1
		# CC.host=${CC} \
		# CFLAGS.host="${CFLAGS}" \
		# CXX.host=${CXX} \
		# CXXFLAGS.host="${CXXFLAGS}" \
		# LDFLAGS.host="${LDFLAGS}" \
		# LINK.host=${CXX} \

BUILD_DEPENDS+= brotli>=1.0.9,1:archivers/brotli \
		c-ares>=1.17.2:dns/c-ares \
		libnghttp2>=1.45.1:www/libnghttp2 \
		libuv>=1.42.0:devel/libuv \
		npm-node16>0:www/npm-node16 \
		objdump:devel/binutils \
		yarn-node16>0:www/yarn-node16

# BINARY_ALIAS=	cc=${CC} c++=${CXX} make=${MAKE}
CACHE_DIR=	${WRKDIR}/cache
CACHE_TXZ=	${DISTNAME}-npm-cache.tar.xz
PACKAGE_TXZ=	${DISTNAME}-pkg-cache.tar.xz
NPM_BIN=	${WRKSRC}/standalone-cli/node_modules/.bin

post-extract:
	${MKDIR} ${CACHE_DIR}
	${MV} ${WRKDIR}/_cacache ${CACHE_DIR}
	# (cd ${CACHE_DIR} && ${TAR} xzf ${CACHE_TXZ} -C .)
	# ${CP} ${DISTDIR}/node-v${NODE_VERSION_PKGFETCH}.tar.gz ${DISTDIR}/node-v${NODE_VERSION_PORTS}.tar.gz \
	# 	${WRKDIR}/.pkg-cache/node

do-build:
	${MKDIR} ${NPM_BIN}
	(cd ${WRKSRC} && npm run prepublishOnly)
	(cd ${WRKSRC}/standalone-cli && npm install && npm run build)

cache-npm-tarball: clean patch
	# do the build outside poudriere to allow network connections
	${MKDIR} ${NPM_BIN}
	(cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} NPM_OFFLINE=0 npm run prepublishOnly)
	(cd ${WRKSRC}/standalone-cli && ${SETENV} ${MAKE_ENV} NPM_OFFLINE=0 npm install)
	# do some cleanup first
	${RM} -r  ${CACHE_DIR}/_cacache/tmp
	(cd ${CACHE_DIR} && ${TAR} caf ${CACHE_TXZ} _cacache -C .)
	mv ${CACHE_DIR}/${CACHE_TXZ} ${DISTDIR}/

cache-pkg-tarball: clean patch
	# do the build outside poudriere to allow network connections
	${MKDIR} ${NPM_BIN}
	# (cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} NPM_OFFLINE=0 npm run prepublishOnly)
	(cd ${WRKSRC}/standalone-cli && ${SETENV} ${MAKE_ENV} NPM_OFFLINE=0 npm install)
	# do some cleanup first
	# ${RM} -r  ${CACHE_DIR}/_cacache/tmp
	(cd ${CACHE_DIR} && ${TAR} caf ${PACKAGE_TXZ} node v* -C .)
	mv ${CACHE_DIR}/${PACKAGE_TXZ} ${DISTDIR}/

.include <bsd.port.mk>
