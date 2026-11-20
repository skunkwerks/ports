PORTNAME=	sghtmltopdf
DISTVERSIONPREFIX=	v
DISTVERSION=	0.5.1
CATEGORIES=	textproc

MAINTAINER=	dch@FreeBSD.org
COMMENT=	HTML to PDF renderer without Chromium, WebKit, or Gecko
WWW=		https://waka.github.io/sghtmltopdf/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		cargo

USE_GITHUB=	yes
GH_ACCOUNT=	waka
GH_PROJECT=	sghtmltopdf

CARGO_INSTALL_PATH=	core

PLIST_FILES=	bin/${PORTNAME}

.include <bsd.port.mk>
