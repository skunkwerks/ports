PORTNAME=	agnos
DISTVERSIONPREFIX=	v
DISTVERSION=	0.1.0
DISTVERSIONSUFFIX=	-beta.1
CATEGORIES=	dns security

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Process ACME-based DNS-01 approvals to obtain TLS certificates
WWW=		https://github.com/krtab/agnos

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE.txt

USES=		cargo ssl
USE_GITHUB=	yes
GH_ACCOUNT=	krtab
GH_TAGNAME=	2b3cc3ea

.include "Makefile.deps"

PLIST_FILES=	bin/agnos

PORTDOCS=	README.md

OPTIONS_DEFINE=	DOCS

post-install-DOCS-on:
	(cd ${WRKSRC} && ${COPYTREE_SHARE} README.md ${STAGEDIR}${DOCSDIR})

.include <bsd.port.mk>
