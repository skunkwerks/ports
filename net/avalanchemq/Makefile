PORTNAME=		avalanchemq
DISTVERSIONPREFIX=	v
DISTVERSION=		1.0.0-alpha.31
PORTREVISION=		1
CATEGORIES=		net

PATCH_SITES=	https://github.com/${GH_ACCOUNT}/${GH_PROJECT}/commit/
PATCHFILES+=	3a73c414b749.patch:-p1 # https://github.com/cloudamqp/avalanchemq/pull/273

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Next-generation AMQP 0.9.1 based message broker

LICENSE=	APACHE20

BUILD_DEPENDS=	crystal:lang/crystal \
		shards:devel/shards

USES=		pkgconfig ssl:build
USE_GITHUB=	yes
GH_ACCOUNT=	cloudamqp
GH_TUPLE=	dch:avalanchemq-lib:${DISTVERSION}:lib

USE_RC_SUBR=	avalanchemq

USERS=		avalanchemq
GROUPS=		avalanchemq

PORTDOCS=	CHANGELOG.md NOTICE README.md SECURITY.md

OPTIONS_DEFINE=	DOCS

SHARDS_ENV=	--release --production --local --no-color --progress --stats --static

post-extract:
	@${MV} ${WRKDIR}/avalanchemq-lib-${DISTVERSION} ${WRKSRC}/lib
	# switch config example into hier(5) compliance
	@${REINPLACE_CMD} -E \
		-e 's,/etc/,${PREFIX}/etc/,' \
		-e 's,/lib/,/db/,' \
		-e 's,/tmp/avalanchemq-http.sock,/var/run/avalanchemq/http.sock,' \
		-e 's,/tmp/avalanchemq.sock,/var/run/avalanchemq/amqp.sock,' \
		${WRKSRC}/extras/config.ini

do-build:
		(cd ${WRKSRC} && ${LOCALBASE}/bin/shards build ${SHARDS_ENV})

do-install:
	${MKDIR} \
		${STAGEDIR}${ETCDIR} \
		${STAGEDIR}/var/db/avalanchemq \
		${STAGEDIR}/var/log/avalanchemq
	${INSTALL_DATA} \
		${WRKSRC}/extras/config.ini \
		${STAGEDIR}${ETCDIR}/config.ini.sample
.for f in mq mqctl mqperf
	${INSTALL_PROGRAM} ${WRKSRC}/bin/avalanche${f} \
		${STAGEDIR}${PREFIX}/bin
.endfor

do-install-DOCS-on:
		${MKDIR} ${STAGEDIR}${DOCSDIR}
.for f in ${PORTDOCS}
		${INSTALL_DATA} ${WRKSRC}/${f} ${STAGEDIR}${DOCSDIR}
.endfor

.include <bsd.port.mk>
