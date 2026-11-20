PORTNAME=	ergo
DISTVERSIONPREFIX=	v
DISTVERSION=	2.19.1
PORTREVISION=	3
CATEGORIES=	irc
PKGNAMESUFFIX=	-irc-server

MAINTAINER=	yuri@FreeBSD.org
COMMENT=	Modern IRC server (daemon/ircd) written in Go
WWW=		https://ergo.chat \
		https://github.com/ergochat/ergo

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:modules

USE_GITHUB=	yes
GH_ACCOUNT=	ergochat

GO_PKGNAME=	github.com/${GH_ACCOUNT}/${PORTNAME}

GO_BUILDFLAGS+=	-tags sqlite

CONFLICTS_INSTALL=	ergo

PLIST_FILES=	bin/${PORTNAME}

.include <bsd.port.mk>
