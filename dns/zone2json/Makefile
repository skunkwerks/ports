PORTNAME=	zone2json
DISTVERSION=	0.0.5
PORTREVISION=	1
CATEGORIES=	dns

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Converts RFC1035-style zonefiles into canonicalised JSON

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${LOCALBASE}/lib/libldns.a:dns/ldns \
		${LOCALBASE}/lib/librabbitmq.a:net/rabbitmq-c \
		${LOCALBASE}/bin/zig:lang/zig

USES=		ssl
USE_GITHUB=	yes

GH_ACCOUNT=	skunkwerks
GH_PROJECT=	zamqp:zamqp zdns:zdns
GH_TAGNAME=	82f4ec0:zamqp cd8a9c9:zdns
GH_SUBDIR=	../zamqp:zamqp ../zdns:zdns

.include <bsd.port.pre.mk>

MAKE_ENV=	DESTDIR=${STAGEDIR}
.if ${ARCH} == aarch64
ZIG_TARGET=	-Dtarget=aarch64-native -Dcpu=generic
.elif ${ARCH} == amd64
ZIG_TARGET=	-Dtarget=x86_64-native -Dcpu=silvermont
.endif
CONFIGURE_ARGS=	--prefix ${PREFIX} \
		${WITH_DEBUG:U-Drelease-safe=true} \
		-Dstatic-ldns=${PREFIX}/lib/libldns.a \
		-Dstatic-rabbitmq=${PREFIX}/lib/librabbitmq.a \
		-Dversion=${DISTVERSION} \
		${ZIG_TARGET} \
		--verbose

USE_RC_SUBR=	zone2json

USERS=		unbound
GROUPS=		unbound

PLIST_FILES=	bin/${PORTNAME} bin/${PORTNAME}-server
PORTDOCS=	README.md

OPTIONS_DEFINE=	DOCS

post-extract:
	@${RM} ${WRKSRC}/test/zones/bad.zone

post-install:
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/bin/zone2json
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/bin/zone2json-server

post-install-DOCS-on:
	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${DOCSDIR}

do-build:
	@(cd ${WRKSRC} && ${MAKE_ENV} zig build ${CONFIGURE_ARGS})

do-install:

do-test:
	@(cd ${WRKSRC} && ${TEST_ENV} zig build test ${CONFIGURE_ARGS})

.include <bsd.port.post.mk>
