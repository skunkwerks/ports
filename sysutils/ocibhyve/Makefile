PORTNAME=	ocibhyve
DISTVERSION=	0.3.1
CATEGORIES=	sysutils
MASTER_SITES=	https://git.sr.ht/~dch/${PORTNAME}/archive/${DISTVERSIONFULL}${EXTRACT_SUFX}?dummy=/

MAINTAINER=	dch@FreeBSD.org
COMMENT=	OCI runtime that runs each container in a bhyve VM
WWW=		https://git.sr.ht/~dch/ocibhyve

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

ONLY_FOR_ARCHS=	aarch64 amd64
ONLY_FOR_ARCHS_REASON=	boot strategies exist for arm64 and amd64 only

BUILD_DEPENDS=	nlohmann-json>=3.11:devel/nlohmann-json

USES=		compiler:c++20-lang meson pkgconfig
MESON_ARGS=	-Dtests=false

SUB_FILES=	ocibhyve.conf pkg-message

PLIST_FILES=	bin/ocibhyve \
		etc/containers/containers.conf.d/ocibhyve.conf \
		libexec/ocibhyve-agent \
		share/examples/ocibhyve/Containerfile \
		share/man/man8/ocibhyve.8.gz \
		share/ocibhyve/agent.json

OPTIONS_DEFINE=		OCIJAIL SLIRP
OPTIONS_DEFAULT=	OCIJAIL SLIRP
OCIJAIL_DESC=		Run podman pod infra containers with ocijail
SLIRP_DESC=		User-mode networking (org.freebsd.bhyve.net=slirp)

OCIJAIL_RUN_DEPENDS=	ocijail:sysutils/ocijail
SLIRP_RUN_DEPENDS=	libslirp>0:net/libslirp

# podman reads this after containers.conf, so --runtime ocibhyve works.
post-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/containers/containers.conf.d
	${INSTALL_DATA} ${WRKDIR}/ocibhyve.conf \
		${STAGEDIR}${PREFIX}/etc/containers/containers.conf.d

.include <bsd.port.mk>
