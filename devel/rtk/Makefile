PORTNAME=	rtk
DISTVERSION=	0.51.1
DISTVERSIONSUFFIX=	-rc.522
CATEGORIES=	devel

MAINTAINER=	lbartoletti@FreeBSD.org
COMMENT=	CLI proxy that reduces LLM token consumption on common dev commands
WWW=		https://www.rtk-ai.app

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		cargo
USE_GITHUB=	yes
GH_ACCOUNT=	rtk-ai
GH_TAGNAME=	dev-${DISTVERSIONFULL}

PLIST_FILES=	bin/rtk

.include <bsd.port.mk>
