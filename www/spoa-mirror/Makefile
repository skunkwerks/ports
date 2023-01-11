PORTNAME=	spoa-mirror
DISTVERSIONPREFIX=	v
DISTVERSION=	1.2.16
CATEGORIES=	www

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Mirror HTTP requests using haproxy stream processing protocol
WWW=		https://github.com/haproxytech/spoa-mirror

LICENSE=	LGPL21

LIB_DEPENDS=	libcurl.so:ftp/curl \
		libev.so:devel/libev

USES=		autoreconf compiler:c++17-lang cpe gmake pkgconfig ssl

MAKE_TARGET=	all

USE_GITHUB=	yes
GH_ACCOUNT=	haproxytech

CPE_VENDOR=	haproxy
SHEBANG_FILES=	share/h2o/start_server

PORTDOCS=	README.md

USE_RC_SUBR=	${PORTNAME}

OPTIONS_DEFINE=	DOCS

pre-configure:
		(cd ${WRKSRC} && ./script/bootstrap)

post-install:
	${MKDIR} ${STAGEDIR}${ETCDIR} \
		${STAGEDIR}${H2O_LOGDIR}
	${INSTALL_DATA} \
		${WRKDIR}/${PORTNAME}.conf.sample \
		${STAGEDIR}${ETCDIR}/${PORTNAME}.conf.sample

post-install-DOCS-on:
	${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${DOCSDIR}

.include <bsd.port.mk>
