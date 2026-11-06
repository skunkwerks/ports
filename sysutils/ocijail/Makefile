PORTNAME=	ocijail
DISTVERSIONPREFIX=	v
DISTVERSION=	0.6.1
PORTREVISION=	1
CATEGORIES=	sysutils

MAINTAINER=	dfr@FreeBSD.org
COMMENT=	Experimental, proof-of-concept OCI-compatible runtime for jails
WWW=		https://github.com/dfr/ocijail

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	cli11>0:devel/cli11 \
		nlohmann-json>=3.11:devel/nlohmann-json

USES=		compiler:c++20-lang meson pkgconfig

USE_GITHUB=	yes
GH_ACCOUNT=	dfr

PLIST_FILES=	bin/ocijail

# Upstream builds with Bazel. Until a release ships this meson.build, the
# port brings its own.
post-extract:
	${CP} ${FILESDIR}/meson.build ${WRKSRC}/

.include <bsd.port.mk>
