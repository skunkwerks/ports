PORTNAME=	literata
DISTVERSION=	3.103
CATEGORIES=	x11-fonts

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Contemporary serif typeface family for long-form reading
WWW=		https://github.com/googlefonts/literata

LICENSE=	OFL11
LICENSE_FILE=	${WRKSRC}/OFL.txt

USES=		fonts
FONTNAME=	Literata
USE_GITHUB=	yes
GH_ACCOUNT=	googlefonts
GH_TAGNAME=	0c2761b727a1b3a7cffd313c37f0f5163dfc7a63

NO_ARCH=	yes
NO_BUILD=	yes

do-install:
	@${MKDIR} ${STAGEDIR}${FONTSDIR}
	${INSTALL_DATA} ${WRKSRC}/fonts/variable/* ${STAGEDIR}${FONTSDIR}

.include <bsd.port.mk>
