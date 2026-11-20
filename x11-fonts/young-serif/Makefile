PORTNAME=	young-serif
DISTVERSION=	g20260519
CATEGORIES=	x11-fonts

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Old style serif typeface inspired by Plantin Infant
WWW=		https://noirblancrouge.com/fonts/young-serif/

LICENSE=	OFL11
LICENSE_FILE=	${WRKSRC}/OFL.txt

USES=		fonts
FONTNAME=	YoungSerif
USE_GITHUB=	yes
GH_ACCOUNT=	noirblancrouge
GH_PROJECT=	YoungSerif
GH_TAGNAME=	8a6c3ceeed5e52bd77b0dfad6b76e99096b9fd4b

NO_ARCH=	yes
NO_BUILD=	yes

do-install:
	@${MKDIR} ${STAGEDIR}${FONTSDIR}
	${INSTALL_DATA} ${WRKSRC}/fonts/variable/* ${STAGEDIR}${FONTSDIR}

.include <bsd.port.mk>
