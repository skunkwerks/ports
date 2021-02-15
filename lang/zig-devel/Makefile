# $FreeBSD$
PORTNAME=	zig
PKGNAMESUFFIX=	-devel
DISTVERSION=	g20210212

CATEGORIES=	lang
MASTER_SITES=	https://ziglang.org/download/${DISTVERSION}/ \
		https://ziglang.org/builds/

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Language designed for robustness, optimality, and maintainability (developer version)

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BROKEN_i386=	static_assert failed "static_assert(sizeof(ZigClangAPValue) == sizeof(clang::APValue), "")"
IGNORE_FreeBSD_11=	expects getrandom(2) which is unavailable on FreeBSD < 12.0

_LLVM_VER=	11
BUILD_DEPENDS=	llvm${_LLVM_VER}>=0:devel/llvm${_LLVM_VER}

USES=		cmake compiler:c++11-lang tar:xz

USE_GITHUB=	yes
GH_ACCOUNT=	ziglang
GH_PROJECT=	zig
GH_TAGNAME=	d3565ed6b

OPTIONS_DEFINE=		STATIC
OPTIONS_DEFAULT=	STATIC

CMAKE_ARGS+=	-DZIG_VERSION="0.8.0-dev.1139+d3565ed6b"

STATIC_RUN_DEPENDS_OFF=	llvm${_LLVM_VER}>=0:devel/llvm${_LLVM_VER}
STATIC_CMAKE_BOOL=	CMAKE_SKIP_INSTALL_RPATH ZIG_STATIC

post-build:
	# Produce the experimental std lib documentation.
	${MKDIR} -p ${WRKDIR}/zigdoc
	${WRKDIR}/.build/zig test ${WRKSRC}/lib/std/std.zig \
		--override-lib-dir ${WRKSRC}/lib \
		-femit-docs=${WRKDIR}/zigdoc \
		-fno-emit-bin

post-install:
	${MKDIR} -p ${STAGEDIR}${DOCSDIR}/std
.for f in data.js main.js index.html
	${INSTALL_MAN} ${WRKDIR}/zigdoc/${f} ${STAGEDIR}${DOCSDIR}/std/
.endfor
.include <bsd.port.mk>
