# $FreeBSD$

PORTNAME=	prince
DISTVERSION=	12.4
CATEGORIES=	print www textproc
MASTER_SITES=	https://www.princexml.com/download/
DISTNAME=	prince-${DISTVERSIONPREFIX}${DISTVERSION}-freebsd11.1-amd64

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Convert HTML to PDF - Beautiful printing with simple CSS

LICENSE=	UNKNOWN
LICENSE_NAME=	commercial
LICENSE_FILE=	${WRKSRC}/LICENSE
LICENSE_PERMS=	dist-mirror no-dist-sell pkg-mirror no-pkg-sell auto-accept

ONLY_FOR_ARCHS=	amd64
ONLY_FOR_ARCHS_REASON=	only available on amd64
.include <bsd.port.pre.mk>
.if ${OSREL:R} > 11
IGNORE=		is for FreeBSD 11.x only
.endif

LIB_DEPENDS=	libfontconfig.so:x11-fonts/fontconfig \
		libcurl.so:ftp/curl \
		libfreetype.so:print/freetype2 \
		libgif.so:graphics/giflib \
		libjpeg.so:graphics/jpeg-turbo \
		liblcms2.so:graphics/lcms2 \
		libpng16.so:graphics/png \
		libtiff.so:graphics/tiff \
		libxml2.so:textproc/libxml2
RUN_DEPENDS=	webfonts>=0:x11-fonts/webfonts \
		xorg-fonts-truetype>0:x11-fonts/xorg-fonts-truetype

USE_LDCONFIG=	yes

NO_BUILD=	yes
PKGMESSAGE=	${WRKSRC}/README

do-install:
		(cd ${WRKSRC} && ./install.sh ${STAGEDIR}${PREFIX})
		${REINPLACE_CMD} -I '' -e 's|${STAGEDIR}||g' \
		    ${STAGEDIR}${PREFIX}/bin/${PORTNAME}

.include <bsd.port.post.mk>
