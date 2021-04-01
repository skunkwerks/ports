# $FreeBSD$

PORTNAME=	zone2json
DISTVERSION=	0.0.2
CATEGORIES=	dns

MAINTAINER=	dch@FreeBSD.org
COMMENT=	converts RFC1035-style zonefiles into canonicalised JSON

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	libldns.so:dns/ldns \
		librabbitmq.so:net/rabbitmq-c-devel \
		zig>0.7.1:lang/zig-devel

USES=		ssl
USE_GITHUB=	yes
GH_ACCOUNT=	skunkwerks

MAKE_ENV=	DESTDIR=${STAGEDIR}
CONFIGURE_ARGS=	--prefix ${PREFIX} ${WITH_DEBUG:U-Drelease-fast=true} --verbose

PLIST_FILES=	bin/${PORTNAME} bin/${PORTNAME}-server

do-build:
	@(cd ${WRKSRC} && ${MAKE_ENV} zig build ${CONFIGURE_ARGS})

do-test:
	@(cd ${WRKSRC} && ${TEST_ENV} zig build test ${CONFIGURE_ARGS})

.include <bsd.port.mk>
