# $FreeBSD$

PORTNAME=	zone2json
DISTVERSION=	0.0.2
CATEGORIES=	dns

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Converts RFC1035-style zonefiles into canonicalised JSON

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${LOCALBASE}/lib/libldns.a:dns/ldns \
		${LOCALBASE}/lib/librabbitmq.a:net/rabbitmq-c-devel \
		${LOCALBASE}/bin/zig:lang/zig-devel

USES=		ssl
USE_GITHUB=	yes
GH_ACCOUNT=	skunkwerks
GH_PROJECT=	zamqp:zamqp zdns:zdns
GH_TAGNAME=	82f4ec0:zamqp cd8a9c9:zdns
GH_SUBDIR=	../zamqp:zamqp ../zdns:zdns

MAKE_ENV=	DESTDIR=${STAGEDIR}
CONFIGURE_ARGS=	--prefix ${PREFIX} \
		${WITH_DEBUG:U-Drelease-fast=true} \
		-Dstatic-ldns=${PREFIX}/lib/libldns.a \
		-Dstatic-rabbitmq=${PREFIX}/lib/librabbitmq.a \
		--verbose

PLIST_FILES=	bin/${PORTNAME} bin/${PORTNAME}-server

do-build:
	@(cd ${WRKSRC} && ${MAKE_ENV} zig build ${CONFIGURE_ARGS})

do-install:

do-test:
	@(cd ${WRKSRC} && ${TEST_ENV} zig build test ${CONFIGURE_ARGS})

.include <bsd.port.mk>
