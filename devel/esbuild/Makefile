PORTNAME=	esbuild
DISTVERSIONPREFIX=	v
# DO NOT UPDATE WITHOUT THIS BEING DONE
# post to phabricator & chromium@ before committing so they can update
DISTVERSION=	${ESBUILD_VERSION}
PORTREVISION=	1
CATEGORIES=	devel www

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Extremely fast JavaScript bundler and minifier
WWW=		https://esbuild.github.io/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE.md

USES=		go:modules
GO_MODULE=	github.com/evanw/${PORTNAME}
GO_TARGET=	./cmd/esbuild:esbuild

PLIST_FILES=	bin/${PORTNAME}

.include "Makefile.version"
.include <bsd.port.mk>
