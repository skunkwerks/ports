PORTNAME=	github-act-runner
DISTVERSIONPREFIX=	v
DISTVERSION=	0.0.8
CATEGORIES=	devel sysutils

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Unofficial GitHub Actions powered runner written in go

LICENSE=	MIT APACHE20
LICENSE_COMB=	multi
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:modules

USE_GITHUB=	yes
GH_ACCOUNT=	ChristopherHX

ETCDIR=		${PREFIX}/etc/github_act_runner

SUB_FILES=	pkg-message

do-build:
	(cd ${WRKSRC} && go build -v -o ${WRKDIR}/${PORTNAME})

do-install:
	${INSTALL_PROGRAM} \
		${WRKDIR}/${PORTNAME} ${STAGEDIR}${PREFIX}/bin/github-act-runner
	${MKDIR} ${STAGEDIR}${ETCDIR}/hooks ${STAGEDIR}${ETCDIR}/plugins

.include <bsd.port.mk>
