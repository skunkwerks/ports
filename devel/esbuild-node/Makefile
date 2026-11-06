PORTNAME=	esbuild
DISTVERSIONPREFIX=	v
DISTVERSION=	${ESBUILD_VERSION}
CATEGORIES=	devel www
MASTER_SITES=	https://proxy.golang.org/github.com/evanw/esbuild/@v/
PKGNAMESUFFIX=	-node
DISTFILES=	${DISTVERSIONFULL}.mod \
		${DISTVERSIONFULL}.zip
DIST_SUBDIR=	go/devel_esbuild/${PORTNAME}-${DISTVERSIONFULL}
EXTRACT_ONLY=	${DISTVERSIONFULL}.zip

MAINTAINER=	chromium@FreeBSD.org
COMMENT=	Node.js API for the esbuild JavaScript bundler
WWW=		https://esbuild.github.io/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE.md

BUILD_DEPENDS=	esbuild:devel/esbuild
RUN_DEPENDS=	esbuild:devel/esbuild

USES=		nodejs zip

NO_ARCH=	yes

WRKSRC=		${WRKDIR}/github.com/evanw/${PORTNAME}@${DISTVERSIONFULL}

DISTINFO_FILE=	${.CURDIR}/../esbuild/distinfo

PLIST_FILES=	lib/node_modules/esbuild/bin/esbuild \
		lib/node_modules/esbuild/install.js \
		lib/node_modules/esbuild/lib/main.d.ts \
		lib/node_modules/esbuild/lib/main.js \
		lib/node_modules/esbuild/LICENSE.md \
		lib/node_modules/esbuild/package.json \
		lib/node_modules/esbuild/README.md

post-patch:
	@${REINPLACE_CMD} -e 's,|| ESBUILD_BINARY_PATH$$,|| "${LOCALBASE}/bin/esbuild",' \
		${WRKSRC}/lib/npm/node-platform.ts

do-build:
	cd ${WRKSRC} && ${LOCALBASE}/bin/node scripts/esbuild.js \
		${LOCALBASE}/bin/esbuild --neutral

do-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/lib/node_modules/esbuild
	cd ${WRKSRC}/npm/esbuild && ${COPYTREE_SHARE} . \
		${STAGEDIR}${PREFIX}/lib/node_modules/esbuild
	${CHMOD} 0755 ${STAGEDIR}${PREFIX}/lib/node_modules/esbuild/bin/esbuild

.include "${.CURDIR}/../esbuild/Makefile.version"
.include <bsd.port.mk>
