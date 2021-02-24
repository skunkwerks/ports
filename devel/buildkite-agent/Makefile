# $FreeBSD$

PORTNAME=	buildkite-agent
DISTVERSIONPREFIX=	v
DISTVERSION=	3.25.0
CATEGORIES=	devel sysutils

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Cross-platform build runner to run your own build tasks

LICENSE=	MIT BSD3CLAUSE APACHE20 LGPL3 BSD2CLAUSE
LICENSE_COMB=	multi
LICENSE_FILE=	${WRKSRC}/LICENSE.txt

RUN_DEPENDS=	bash:shells/bash

USES=		go:modules

USE_GITHUB=	yes
GH_ACCOUNT=	buildkite
GH_PROJECT=	agent
GH_TUPLE=	\
		DataDog:datadog-go:281ae9f2d895:datadog_datadog_go/vendor/github.com/DataDog/datadog-go \
		aws:aws-sdk-go:v1.32.10:aws_aws_sdk_go/vendor/github.com/aws/aws-sdk-go \
		buildkite:bintest:v3.1.0:buildkite_bintest_v3/vendor/github.com/buildkite/bintest/v3 \
		buildkite:interpolate:07f35b4ae251:buildkite_interpolate/vendor/github.com/buildkite/interpolate \
		buildkite:shellwords:c3f497d1e000:buildkite_shellwords/vendor/github.com/buildkite/shellwords \
		buildkite:yaml:0caa5f0796e3:buildkite_yaml/vendor/github.com/buildkite/yaml \
		cpuguy83:go-md2man:f79a8a8ca69d:cpuguy83_go_md2man_v2/vendor/github.com/cpuguy83/go-md2man/v2 \
		davecgh:go-spew:v1.1.1:davecgh_go_spew/vendor/github.com/davecgh/go-spew \
		denisbrodbeck:machineid:v1.0.0:denisbrodbeck_machineid/vendor/github.com/denisbrodbeck/machineid \
		go-check:check:788fd7840127:go_check_check/vendor/gopkg.in/check.v1 \
		go-yaml:yaml:v2.2.2:go_yaml_yaml/vendor/gopkg.in/yaml.v2 \
		golang:appengine:v1.2.0:golang_appengine/vendor/google.golang.org/appengine \
		golang:crypto:78000ba7a073:golang_crypto/vendor/golang.org/x/crypto \
		golang:net:16171245cfb2:golang_net/vendor/golang.org/x/net \
		golang:oauth2:c57b0facaced:golang_oauth2/vendor/golang.org/x/oauth2 \
		golang:protobuf:v1.2.0:golang_protobuf/vendor/github.com/golang/protobuf \
		golang:sync:1d60e4601c6f:golang_sync/vendor/golang.org/x/sync \
		golang:sys:dfb3f7c4e634:golang_sys/vendor/golang.org/x/sys \
		golang:text:v0.3.0:golang_text/vendor/golang.org/x/text \
		google:go-querystring:53e6ce116135:google_go_querystring/vendor/github.com/google/go-querystring \
		googleapis:gax-go:da06d194a00e:googleapis_gax_go/vendor/github.com/googleapis/gax-go \
		googleapis:google-api-go-client:cc9bd73d51b4:googleapis_google_api_go_client/vendor/google.golang.org/api \
		googleapis:google-cloud-go:65216237311a:googleapis_google_cloud_go/vendor/cloud.google.com/go \
		grpc:grpc-go:d0c32ee6a441:grpc_grpc_go/vendor/google.golang.org/grpc \
		jmespath:go-jmespath:v0.3.0:jmespath_go_jmespath/vendor/github.com/jmespath/go-jmespath \
		kr:pretty:v0.1.0:kr_pretty/vendor/github.com/kr/pretty \
		kr:pty:v1.1.2:kr_pty/vendor/github.com/kr/pty \
		mattn:go-zglob:2ea3427bfa53:mattn_go_zglob/vendor/github.com/mattn/go-zglob \
		mitchellh:go-homedir:v1.0.0:mitchellh_go_homedir/vendor/github.com/mitchellh/go-homedir \
		nightlyone:lockfile:0ad87eef1443:nightlyone_lockfile/vendor/github.com/nightlyone/lockfile \
		oleiade:reflections:0e86b3c98b2f:oleiade_reflections/vendor/github.com/oleiade/reflections \
		pborman:uuid:1b00554d8222:pborman_uuid/vendor/github.com/pborman/uuid \
		petermattis:goid:b0b1615b78e5:petermattis_goid/vendor/github.com/petermattis/goid \
		pkg:errors:v0.9.1:pkg_errors/vendor/github.com/pkg/errors \
		pmezard:go-difflib:v1.0.0:pmezard_go_difflib/vendor/github.com/pmezard/go-difflib \
		qri-io:jsonpointer:168dd9e45cf2:qri_io_jsonpointer/vendor/github.com/qri-io/jsonpointer \
		qri-io:jsonschema:d0d3b10ec792:qri_io_jsonschema/vendor/github.com/qri-io/jsonschema \
		russross:blackfriday:v2.0.1:russross_blackfriday_v2/vendor/github.com/russross/blackfriday/v2 \
		sasha-s:go-deadlock:237a9547c8a5:sasha_s_go_deadlock/vendor/github.com/sasha-s/go-deadlock \
		sergi:go-diff:v1.0.0:sergi_go_diff/vendor/github.com/sergi/go-diff \
		shurcooL:sanitized_anchor_name:v1.0.0:shurcool_sanitized_anchor_name/vendor/github.com/shurcooL/sanitized_anchor_name \
		stretchr:testify:v1.5.1:stretchr_testify/vendor/github.com/stretchr/testify \
		urfave:cli:v1.22.4:urfave_cli/vendor/github.com/urfave/cli

# GO_BUILDFLAGS=	-i -o ${PREFIX}/buildkite-agent
USE_RC_SUBR=	buildkite

ETCDIR=		${PREFIX}/etc/buildkite

SUB_FILES=	pkg-message

post-patch:
	@${REINPLACE_CMD} -I '' -e 's|/bin/bash|${LOCALBASE}/bin/bash|g' \
			`${FIND} ${WRKSRC}/packaging/linux -type f`
	@${REINPLACE_CMD} -I '' -e 's|/bin/bash|${LOCALBASE}/bin/bash|g' \
			`${FIND} ${WRKSRC}/bootstrap -type f -name *.go`

do-install:
	${INSTALL_PROGRAM} \
		${WRKDIR}/bin/${PORTNAME} ${STAGEDIR}${PREFIX}/bin/${PORTNAME}
	${MKDIR} ${STAGEDIR}${ETCDIR}/hooks ${STAGEDIR}${ETCDIR}/plugins
	${INSTALL_DATA} \
		${WRKSRC}/packaging/github/linux/${PORTNAME}.cfg \
		${STAGEDIR}${ETCDIR}/${PORTNAME}.cfg.sample

post-install:
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	(cd ${WRKSRC}/packaging/linux/root/usr/share/${PORTNAME} && ${COPYTREE_SHARE} hooks ${STAGEDIR}${EXAMPLESDIR})

.include <bsd.port.mk>
