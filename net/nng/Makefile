PORTNAME=	nng
PORTREVISION=	1
DISTVERSIONPREFIX=	v
DISTVERSION=	1.4.0
CATEGORIES=	net

PATCH_SITES=	https://github.com/${GH_ACCOUNT}/${GH_PROJECT}/pull/
PATCHFILES+=	1423.patch:-p1 # https://github.com/nanomgs/nng/pull.1423.patch

MAINTAINER=	swills@FreeBSD.org
COMMENT=	Lightweight, broker-less messaging

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE.txt

USES=		cmake compiler:c11
USE_GITHUB=	yes
GH_ACCOUNT=	nanomsg

CMAKE_ARGS+=	-DBUILD_SHARED_LIBS:BOOL=ON
USE_LDCONFIG=	yes

PLIST_SUB=	PORTMAJ=${PORTVERSION:C/\..*//} \
		PORTVERSION=${PORTVERSION}

.include <bsd.port.mk>
