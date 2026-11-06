PORTNAME=	katarakt
PORTVERSION=	0.2
PORTREVISION=	35
CATEGORIES=	graphics

MAINTAINER=	kurt@kmk-computers.de
COMMENT=	Simple PDF viewer uses as much available screen space as possible
WWW=		https://gitlab.cs.fau.de/Qui_Sum/katarakt

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	a2x:textproc/asciidoc
LIB_DEPENDS=	libpoppler-qt5.so:graphics/poppler-qt5

USES=		compiler:c++11-lang desktop-file-utils gl pkgconfig qmake qt:5

USE_GITLAB=	yes
GL_SITE=	https://gitlab.cs.fau.de
GL_ACCOUNT=	Qui_Sum
GL_TAGNAME=	99735bc0b15b57d689b6c982d43b85ed1b40ef45

USE_GL=		gl
USE_QT=		core dbus gui network widgets xml buildtools:build

SUB_FILES=	katarakt.desktop

PLIST_FILES=	bin/katarakt \
		share/applications/katarakt.desktop \
		share/man/man1/katarakt.1.gz

post-build:
	cd ${WRKSRC} && ${MAKE} doc

post-install:
	${INSTALL_MAN} ${WRKSRC}/doc/katarakt.1 ${STAGEDIR}${PREFIX}/share/man/man1
	${INSTALL_DATA} ${WRKDIR}/katarakt.desktop ${STAGEDIR}${DESKTOPDIR}

.include <bsd.port.mk>
