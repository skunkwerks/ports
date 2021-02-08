# $FreeBSD$

PORTNAME=	owncast
DISTVERSIONPREFIX=	v
DISTVERSION=	0.0.5

CATEGORIES=	multimedia www

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Self-hosted video and web chat server for live streaming

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:modules
USE_GITHUB=	yes

USE_RC_SUBR=	owncast

USERS=		www
GROUPS=		www

SUB_FILES=	pkg-message

GH_TUPLE=	\
		StackExchange:wmi:cbe66965904d:stackexchange_wmi/vendor/github.com/StackExchange/wmi \
		amalfra:etag:cafc8de96bc5:amalfra_etag/vendor/github.com/amalfra/etag \
		aws:aws-sdk-go:v1.36.23:aws_aws_sdk_go/vendor/github.com/aws/aws-sdk-go \
		aymerick:douceur:v0.2.0:aymerick_douceur/vendor/github.com/aymerick/douceur \
		chris-ramon:douceur:v0.2.0:chris_ramon_douceur \
		go-check:check:8fa46927fb4f:go_check_check/vendor/gopkg.in/check.v1 \
		go-ole:go-ole:v1.2.4:go_ole_go_ole/vendor/github.com/go-ole/go-ole \
		go-yaml:yaml:v2.4.0:go_yaml_yaml/vendor/gopkg.in/yaml.v2 \
		gobuffalo:here:v0.6.0:gobuffalo_here/vendor/github.com/gobuffalo/here \
		golang:mod:v0.4.0:golang_mod/vendor/golang.org/x/mod \
		golang:net:69a78807bb2b:golang_net/vendor/golang.org/x/net \
		golang:sys:fdedc70b468f:golang_sys/vendor/golang.org/x/sys \
		golang:time:7e3f01d25324:golang_time/vendor/golang.org/x/time \
		gorilla:css:v1.0.0:gorilla_css/vendor/github.com/gorilla/css \
		grafov:m3u8:v0.11.1:grafov_m3u8/vendor/github.com/grafov/m3u8 \
		jmespath:go-jmespath:v0.4.0:jmespath_go_jmespath/vendor/github.com/jmespath/go-jmespath \
		markbates:pkger:v0.17.1:markbates_pkger/vendor/github.com/markbates/pkger \
		mattn:go-sqlite3:v1.14.6:mattn_go_sqlite3/vendor/github.com/mattn/go-sqlite3 \
		microcosm-cc:bluemonday:v1.0.4:microcosm_cc_bluemonday/vendor/github.com/microcosm-cc/bluemonday \
		mssola:user_agent:v0.5.2:mssola_user_agent/vendor/github.com/mssola/user_agent \
		mvdan:xurls:v1.1.0:mvdan_xurls/vendor/github.com/mvdan/xurls \
		mvdan:xurls:v1.1.0:mvdan_xurls_1/vendor/mvdan.cc/xurls \
		nareix:joy5:a55089207c88:nareix_joy5/vendor/github.com/nareix/joy5 \
		niemeyer:pretty:a10e7caefd8e:niemeyer_pretty/vendor/github.com/niemeyer/pretty \
		oschwald:geoip2-golang:v1.4.0:oschwald_geoip2_golang/vendor/github.com/oschwald/geoip2-golang \
		oschwald:maxminddb-golang:v1.6.0:oschwald_maxminddb_golang/vendor/github.com/oschwald/maxminddb-golang \
		shirou:gopsutil:v2.20.9:shirou_gopsutil/vendor/github.com/shirou/gopsutil \
		sirupsen:logrus:v1.7.0:sirupsen_logrus/vendor/github.com/sirupsen/logrus \
		teris-io:shortid:771a37caa5cf:teris_io_shortid/vendor/github.com/teris-io/shortid \
		yuin:goldmark:v1.3.1:yuin_goldmark/vendor/github.com/yuin/goldmark

GO_BUILDFLAGS=	-ldflags="-s -w \
		-X main.BuildVersion=${PORTVERSION} \
		-X main.BuildType=FreeBSD \
		-X main.GitCommit=${DISTVERSION}${DISTVERSION-SUFFIX}"

post-extract:
	@${MKDIR} ${WRKSRC}/vendor/github.com/chris-ramon
	@${RLN} ${WRKSRC_aymerick_douceur} ${WRKSRC}/vendor/github.com/chris-ramon/douceur

pre-install:
	# relocate user-modifiable runtime configs to match hier(7)
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${WRKSRC}/config-default.yaml \
		${STAGEDIR}${ETCDIR}/owncast.yaml.sample

post-install:
	@${MKDIR} ${STAGEDIR}/var/db/${PORTNAME}
	# (cd ${WRKSRC}/share/www && ${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR})

.include <bsd.port.mk>
