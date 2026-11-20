PORTNAME=	lameenc
DISTVERSIONPREFIX=	v
DISTVERSION=	1.9.0
CATEGORIES=	audio python
PKGNAMEPREFIX=	${PYTHON_PKGNAMEPREFIX}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Python bindings for the LAME MP3 encoder
WWW=		https://github.com/chrisstaite/lameenc

LICENSE=	LGPL3+
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${PYTHON_PKGNAMEPREFIX}setuptools-scm>0:devel/py-setuptools-scm@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}wheel>0:devel/py-wheel@${PY_FLAVOR}
LIB_DEPENDS=	libmp3lame.so:audio/lame

USES=		localbase python
USE_GITHUB=	yes
GH_ACCOUNT=	chrisstaite
USE_PYTHON=	autoplist concurrent pep517

MAKE_ENV=	SETUPTOOLS_SCM_PRETEND_VERSION=${DISTVERSION}

CFLAGS+=	-I${LOCALBASE}/include/lame

post-install:
	${STRIP_CMD} ${STAGEDIR}${PYTHON_SITELIBDIR}/lameenc*.so

.include <bsd.port.mk>
