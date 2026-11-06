PORTNAME=	bandcampsync
DISTVERSION=	0.8.0
CATEGORIES=	audio python
MASTER_SITES=	PYPI
PKGNAMEPREFIX=	${PYTHON_PKGNAMEPREFIX}

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Synchronise media purchased on bandcamp.com to a local directory
WWW=		https://github.com/meeb/bandcampsync

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${PYTHON_PKGNAMEPREFIX}setuptools>=0:devel/py-setuptools@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}wheel>0:devel/py-wheel@${PY_FLAVOR}
RUN_DEPENDS=	${PYTHON_PKGNAMEPREFIX}beautifulsoup4>=4.14.3:www/py-beautifulsoup4@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}curl-cffi>=0.14.0:ftp/py-curl-cffi@${PY_FLAVOR}

USES=		python:3.10+
USE_PYTHON=	autoplist pep517

NO_ARCH=	yes

.include <bsd.port.mk>
