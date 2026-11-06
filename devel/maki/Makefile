PORTNAME=	maki
DISTVERSIONPREFIX=	v
DISTVERSION=	0.6.5
CATEGORIES=	devel

MAINTAINER=	lbartoletti@FreeBSD.org
COMMENT=	Efficient AI coding agent
WWW=		https://maki.sh

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

RUN_DEPENDS=	bash:shells/bash

USES=		cargo pkgconfig python:build
USE_GITHUB=	yes
GH_ACCOUNT=	tontinton

CARGO_BUILD_ARGS+=	--config='profile.release.panic="unwind"'
CARGO_INSTALL_ARGS+=	--config='profile.release.panic="unwind"'

MAKE_ENV+=	PYO3_PYTHON=${PYTHON_CMD}

BINARY_ALIAS=	python3=${PYTHON_CMD}

PLIST_FILES=	bin/maki

.include <bsd.port.mk>
