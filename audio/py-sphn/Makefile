PORTNAME=	sphn
DISTVERSION=	0.2.1
CATEGORIES=	audio python
MASTER_SITES=	PYPI
PKGNAMEPREFIX=	${PYTHON_PKGNAMEPREFIX}
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Python bindings for reading, writing and resampling audio
WWW=		https://github.com/kyutai-labs/sphn

LICENSE=	APACHE20 MIT
LICENSE_COMB=	dual
LICENSE_FILE_APACHE20=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${PYTHON_PKGNAMEPREFIX}maturin>=1.4:devel/py-maturin@${PY_FLAVOR}
LIB_DEPENDS=	libopus.so:audio/opus
RUN_DEPENDS=	${PYTHON_PKGNAMEPREFIX}numpy>0:math/py-numpy@${PY_FLAVOR}

USES=		cargo pkgconfig python
USE_PYTHON=	autoplist pep517

CARGO_BUILD=		no
CARGO_INSTALL=		no
CARGO_TEST=		no
CARGO_TARGET_DIR=	${WRKSRC}/target

MAKE_ENV=	${CARGO_ENV}

post-install:
	${STRIP_CMD} ${STAGEDIR}${PYTHON_SITELIBDIR}/sphn/sphn*.so

.include <bsd.port.mk>
