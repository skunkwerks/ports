# $FreeBSD$

PORTNAME=	dkron
PORTVERSION=	3.1.1
DISTVERSIONPREFIX=	v
CATEGORIES=	sysutils

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Distributed Fault-tolerant cron-like job scheduling system

LICENSE=	LGPL3
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:modules

USE_GITHUB=	yes
GH_ACCOUNT=	distribworks

USE_RC_SUBR=	dkron

USERS=		dkron
GROUPS=		dkron

GH_TUPLE=	\
		Azure:azure-sdk-for-go:v16.0.0:azure_azure_sdk_for_go/vendor/github.com/Azure/azure-sdk-for-go \
		Azure:go-autorest:v10.7.0:azure_go_autorest/vendor/github.com/Azure/go-autorest \
		DataDog:datadog-go:v4.0.0:datadog_datadog_go/vendor/github.com/DataDog/datadog-go \
		armon:circbuf:5111143e8da2:armon_circbuf/vendor/github.com/armon/circbuf \
		armon:go-metrics:v0.3.5:armon_go_metrics/vendor/github.com/armon/go-metrics \
		aws:aws-sdk-go:v1.34.17:aws_aws_sdk_go/vendor/github.com/aws/aws-sdk-go \
		beorn7:perks:v1.0.1:beorn7_perks/vendor/github.com/beorn7/perks \
		bmizerany:assert:b7ed37b82869:bmizerany_assert/vendor/github.com/bmizerany/assert \
		boltdb:bolt:v1.3.1:boltdb_bolt/vendor/github.com/boltdb/bolt \
		census-instrumentation:opencensus-go:v0.22.4:census_instrumentation_opencensus_go/vendor/go.opencensus.io \
		cespare:xxhash:v2.1.1:cespare_xxhash_v2/vendor/github.com/cespare/xxhash/v2 \
		cpuguy83:go-md2man:v2.0.0:cpuguy83_go_md2man_v2/vendor/github.com/cpuguy83/go-md2man/v2 \
		davecgh:go-spew:v1.1.1:davecgh_go_spew/vendor/github.com/davecgh/go-spew \
		denverdino:aliyungo:d3308649c661:denverdino_aliyungo/vendor/github.com/denverdino/aliyungo \
		dgrijalva:jwt-go:v3.2.0:dgrijalva_jwt_go/vendor/github.com/dgrijalva/jwt-go \
		digitalocean:godo:v1.1.1:digitalocean_godo/vendor/github.com/digitalocean/godo \
		dimchansky:utfbom:v1.1.0:dimchansky_utfbom/vendor/github.com/dimchansky/utfbom \
		fatih:color:v1.9.0:fatih_color/vendor/github.com/fatih/color \
		fluent:fluent-logger-golang:v1.5.0:fluent_fluent_logger_golang/vendor/github.com/fluent/fluent-logger-golang \
		fsnotify:fsnotify:v1.4.7:fsnotify_fsnotify/vendor/github.com/fsnotify/fsnotify \
		ghodss:yaml:v1.0.0:ghodss_yaml/vendor/github.com/ghodss/yaml \
		gin-contrib:cors:v1.3.1:gin_contrib_cors/vendor/github.com/gin-contrib/cors \
		gin-contrib:expvar:v0.0.1:gin_contrib_expvar/vendor/github.com/gin-contrib/expvar \
		gin-contrib:multitemplate:3e397ee01bc6:gin_contrib_multitemplate/vendor/github.com/gin-contrib/multitemplate \
		gin-contrib:sse:v0.1.0:gin_contrib_sse/vendor/github.com/gin-contrib/sse \
		gin-gonic:gin:v1.6.3:gin_gonic_gin/vendor/github.com/gin-gonic/gin \
		go-inf:inf:v0.9.1:go_inf_inf/vendor/gopkg.in/inf.v0 \
		go-ini:ini:v1.51.0:go_ini_ini/vendor/gopkg.in/ini.v1 \
		go-playground:locales:v0.13.0:go_playground_locales/vendor/github.com/go-playground/locales \
		go-playground:universal-translator:v0.17.0:go_playground_universal_translator/vendor/github.com/go-playground/universal-translator \
		go-playground:validator:v10.2.0:go_playground_validator_v10/vendor/github.com/go-playground/validator/v10 \
		go-resty:resty:v1.12.0:go_resty_resty/vendor/gopkg.in/resty.v1 \
		go-yaml:yaml:9f266ea9e77c:go_yaml_yaml_1/vendor/gopkg.in/yaml.v3 \
		go-yaml:yaml:v2.3.0:go_yaml_yaml/vendor/gopkg.in/yaml.v2 \
		gogo:protobuf:v1.3.1:gogo_protobuf/vendor/github.com/gogo/protobuf \
		golang:appengine:v1.6.6:golang_appengine/vendor/google.golang.org/appengine \
		golang:crypto:75b288015ac9:golang_crypto/vendor/golang.org/x/crypto \
		golang:glog:23def4e6c14b:golang_glog/vendor/github.com/golang/glog \
		golang:groupcache:8c9f03a8e57e:golang_groupcache/vendor/github.com/golang/groupcache \
		golang:net:c89045814202:golang_net/vendor/golang.org/x/net \
		golang:oauth2:5d25da1a8d43:golang_oauth2/vendor/golang.org/x/oauth2 \
		golang:protobuf:v1.4.3:golang_protobuf/vendor/github.com/golang/protobuf \
		golang:sync:6e8e738ad208:golang_sync/vendor/golang.org/x/sync \
		golang:sys:e3ed0017c211:golang_sys/vendor/golang.org/x/sys \
		golang:text:v0.3.3:golang_text/vendor/golang.org/x/text \
		golang:time:555d28b269f0:golang_time/vendor/golang.org/x/time \
		google:btree:v1.0.0:google_btree/vendor/github.com/google/btree \
		google:go-genproto:0bd0a958aa1d:google_go_genproto/vendor/google.golang.org/genproto \
		google:go-querystring:53e6ce116135:google_go_querystring/vendor/github.com/google/go-querystring \
		google:gofuzz:v1.0.0:google_gofuzz/vendor/github.com/google/gofuzz \
		googleapis:gax-go:v2.0.5:googleapis_gax_go_v2/vendor/github.com/googleapis/gax-go \
		googleapis:gnostic:v0.2.0:googleapis_gnostic/vendor/github.com/googleapis/gnostic \
		googleapis:google-api-go-client:v0.35.0:googleapis_google_api_go_client/vendor/google.golang.org/api \
		googleapis:google-cloud-go:v0.65.0:googleapis_google_cloud_go/vendor/cloud.google.com/go \
		gophercloud:gophercloud:f29afc2cceca:gophercloud_gophercloud/vendor/github.com/gophercloud/gophercloud \
		gregjones:httpcache:9cad4c3443a7:gregjones_httpcache/vendor/github.com/gregjones/httpcache \
		grpc:grpc-go:9da74c039bbf:grpc_grpc_go_1/vendor/google.golang.org/grpc/examples \
		grpc:grpc-go:v1.34.0:grpc_grpc_go/vendor/google.golang.org/grpc \
		hashicorp:errwrap:v1.0.0:hashicorp_errwrap/vendor/github.com/hashicorp/errwrap \
		hashicorp:go-discover:7698de1390a1:hashicorp_go_discover/vendor/github.com/hashicorp/go-discover \
		hashicorp:go-hclog:v0.15.0:hashicorp_go_hclog/vendor/github.com/hashicorp/go-hclog \
		hashicorp:go-immutable-radix:v1.2.0:hashicorp_go_immutable_radix/vendor/github.com/hashicorp/go-immutable-radix \
		hashicorp:go-msgpack:v0.5.5:hashicorp_go_msgpack/vendor/github.com/hashicorp/go-msgpack \
		hashicorp:go-multierror:v1.1.0:hashicorp_go_multierror/vendor/github.com/hashicorp/go-multierror \
		hashicorp:go-plugin:v1.4.0:hashicorp_go_plugin/vendor/github.com/hashicorp/go-plugin \
		hashicorp:go-sockaddr:v1.0.2:hashicorp_go_sockaddr/vendor/github.com/hashicorp/go-sockaddr \
		hashicorp:go-syslog:v1.0.0:hashicorp_go_syslog/vendor/github.com/hashicorp/go-syslog \
		hashicorp:go-uuid:v1.0.1:hashicorp_go_uuid/vendor/github.com/hashicorp/go-uuid \
		hashicorp:go-version:v1.2.1:hashicorp_go_version/vendor/github.com/hashicorp/go-version \
		hashicorp:golang-lru:v0.5.4:hashicorp_golang_lru/vendor/github.com/hashicorp/golang-lru \
		hashicorp:hcl:v1.0.0:hashicorp_hcl/vendor/github.com/hashicorp/hcl \
		hashicorp:mdns:v1.0.1:hashicorp_mdns/vendor/github.com/hashicorp/mdns \
		hashicorp:memberlist:v0.2.2:hashicorp_memberlist/vendor/github.com/hashicorp/memberlist \
		hashicorp:raft-boltdb:4207f1bf0617:hashicorp_raft_boltdb/vendor/github.com/hashicorp/raft-boltdb \
		hashicorp:raft:v1.2.0:hashicorp_raft/vendor/github.com/hashicorp/raft \
		hashicorp:serf:v0.9.5:hashicorp_serf/vendor/github.com/hashicorp/serf \
		hashicorp:vic:bbfe86ec9443:hashicorp_vic/vendor/github.com/hashicorp/vic \
		hashicorp:yamux:df201c70410d:hashicorp_yamux/vendor/github.com/hashicorp/yamux \
		imdario:mergo:v0.3.6:imdario_mergo/vendor/github.com/imdario/mergo \
		inconshreveable:mousetrap:v1.0.0:inconshreveable_mousetrap/vendor/github.com/inconshreveable/mousetrap \
		jmespath:go-jmespath:v0.3.0:jmespath_go_jmespath/vendor/github.com/jmespath/go-jmespath \
		jordan-wright:email:94ae17dedda2:jordan_wright_email/vendor/github.com/jordan-wright/email \
		joyent:triton-go:830d2b111e62:joyent_triton_go/vendor/github.com/joyent/triton-go \
		json-iterator:go:v1.1.10:json_iterator_go/vendor/github.com/json-iterator/go \
		kardianos:osext:2bc1f35cddc0:kardianos_osext/vendor/github.com/kardianos/osext \
		kubernetes:api:61b11ee65332:kubernetes_api/vendor/k8s.io/api \
		kubernetes:apimachinery:488889b0007f:kubernetes_apimachinery/vendor/k8s.io/apimachinery \
		kubernetes:client-go:v8.0.0:kubernetes_client_go/vendor/k8s.io/client-go \
		leodido:go-urn:v1.2.0:leodido_go_urn/vendor/github.com/leodido/go-urn \
		linode:linodego:v0.7.1:linode_linodego/vendor/github.com/linode/linodego \
		magiconair:properties:v1.8.1:magiconair_properties/vendor/github.com/magiconair/properties \
		mattn:go-colorable:v0.1.6:mattn_go_colorable/vendor/github.com/mattn/go-colorable \
		mattn:go-isatty:v0.0.12:mattn_go_isatty/vendor/github.com/mattn/go-isatty \
		mattn:go-shellwords:v1.0.10:mattn_go_shellwords/vendor/github.com/mattn/go-shellwords \
		matttproud:golang_protobuf_extensions:v1.0.1:matttproud_golang_protobuf_extensions/vendor/github.com/matttproud/golang_protobuf_extensions \
		miekg:dns:v1.1.26:miekg_dns/vendor/github.com/miekg/dns \
		mitchellh:go-homedir:v1.1.0:mitchellh_go_homedir/vendor/github.com/mitchellh/go-homedir \
		mitchellh:go-testing-interface:v1.14.1:mitchellh_go_testing_interface/vendor/github.com/mitchellh/go-testing-interface \
		mitchellh:mapstructure:v1.1.2:mitchellh_mapstructure/vendor/github.com/mitchellh/mapstructure \
		modern-go:concurrent:bacd9c7ef1dd:modern_go_concurrent/vendor/github.com/modern-go/concurrent \
		modern-go:reflect2:v1.0.1:modern_go_reflect2/vendor/github.com/modern-go/reflect2 \
		nicolai86:scaleway-sdk:798f60e20bb2:nicolai86_scaleway_sdk/vendor/github.com/nicolai86/scaleway-sdk \
		oklog:run:v1.0.0:oklog_run/vendor/github.com/oklog/run \
		packethost:packngo:b9cb5096f54c:packethost_packngo/vendor/github.com/packethost/packngo \
		pelletier:go-toml:v1.2.0:pelletier_go_toml/vendor/github.com/pelletier/go-toml \
		peterbourgon:diskv:v2.0.1:peterbourgon_diskv/vendor/github.com/peterbourgon/diskv \
		philhofer:fwd:v1.0.0:philhofer_fwd/vendor/github.com/philhofer/fwd \
		pkg:errors:v0.9.1:pkg_errors/vendor/github.com/pkg/errors \
		pmezard:go-difflib:v1.0.0:pmezard_go_difflib/vendor/github.com/pmezard/go-difflib \
		prometheus:client_golang:v1.8.0:prometheus_client_golang/vendor/github.com/prometheus/client_golang \
		prometheus:client_model:v0.2.0:prometheus_client_model/vendor/github.com/prometheus/client_model \
		prometheus:common:v0.14.0:prometheus_common/vendor/github.com/prometheus/common \
		prometheus:procfs:v0.2.0:prometheus_procfs/vendor/github.com/prometheus/procfs \
		protocolbuffers:protobuf-go:v1.25.0:protocolbuffers_protobuf_go/vendor/google.golang.org/protobuf \
		renier:xmlrpc:ce4a1a486c03:renier_xmlrpc/vendor/github.com/renier/xmlrpc \
		robfig:cron:v3.0.1:robfig_cron_v3/vendor/github.com/robfig/cron/v3 \
		russross:blackfriday:v2.0.1:russross_blackfriday_v2/vendor/github.com/russross/blackfriday/v2 \
		ryanuber:columnize:v2.1.2:ryanuber_columnize/vendor/github.com/ryanuber/columnize \
		sean-:seed:e2103e2c3529:sean__seed/vendor/github.com/sean-/seed \
		shurcooL:sanitized_anchor_name:v1.0.0:shurcool_sanitized_anchor_name/vendor/github.com/shurcooL/sanitized_anchor_name \
		sirupsen:logrus:v1.7.0:sirupsen_logrus/vendor/github.com/sirupsen/logrus \
		softlayer:softlayer-go:260589d94c7d:softlayer_softlayer_go/vendor/github.com/softlayer/softlayer-go \
		soheilhy:cmux:v0.1.4:soheilhy_cmux/vendor/github.com/soheilhy/cmux \
		spf13:afero:v1.1.2:spf13_afero/vendor/github.com/spf13/afero \
		spf13:cast:v1.3.0:spf13_cast/vendor/github.com/spf13/cast \
		spf13:cobra:v1.1.1:spf13_cobra/vendor/github.com/spf13/cobra \
		spf13:jwalterweatherman:v1.0.0:spf13_jwalterweatherman/vendor/github.com/spf13/jwalterweatherman \
		spf13:pflag:v1.0.5:spf13_pflag/vendor/github.com/spf13/pflag \
		spf13:viper:v1.7.1:spf13_viper/vendor/github.com/spf13/viper \
		streadway:amqp:v1.0.0:streadway_amqp/vendor/github.com/streadway/amqp \
		stretchr:testify:v1.6.1:stretchr_testify/vendor/github.com/stretchr/testify \
		subosito:gotenv:v1.2.0:subosito_gotenv/vendor/github.com/subosito/gotenv \
		tencentcloud:tencentcloud-sdk-go:v3.0.83:tencentcloud_tencentcloud_sdk_go/vendor/github.com/tencentcloud/tencentcloud-sdk-go \
		tent:http-link-go:ac974c61c2f9:tent_http_link_go/vendor/github.com/tent/http-link-go \
		tidwall:btree:v0.2.2:tidwall_btree/vendor/github.com/tidwall/btree \
		tidwall:buntdb:v1.1.5:tidwall_buntdb/vendor/github.com/tidwall/buntdb \
		tidwall:gjson:v1.6.1:tidwall_gjson/vendor/github.com/tidwall/gjson \
		tidwall:grect:ba9a043346eb:tidwall_grect/vendor/github.com/tidwall/grect \
		tidwall:match:v1.0.1:tidwall_match/vendor/github.com/tidwall/match \
		tidwall:pretty:v1.0.2:tidwall_pretty/vendor/github.com/tidwall/pretty \
		tidwall:rtree:32188eeb08a8:tidwall_rtree/vendor/github.com/tidwall/rtree \
		tidwall:tinyqueue:1e39f5511563:tidwall_tinyqueue/vendor/github.com/tidwall/tinyqueue \
		tinylib:msgp:v1.1.2:tinylib_msgp/vendor/github.com/tinylib/msgp \
		ugorji:go:v1.1.7:ugorji_go_codec/vendor/github.com/ugorji/go \
		vmware:govmomi:v0.18.0:vmware_govmomi/vendor/github.com/vmware/govmomi
post-patch:
	# respect hier(7) in both src and docs
	${REINPLACE_CMD} \
		-e 's|/var/lib/dkron|/var/db/dkron|g' \
		-e 's|/etc/dkron|${ETCDIR}|g' \
		${WRKSRC}/cmd/*.go ${WRKSRC}/dkron/*.go

post-install:
	${MKDIR} \
		${STAGEDIR}${ETCDIR} \
		${STAGEDIR}/var/db/${PORTNAME} \
		${STAGEDIR}/var/log/${PORTNAME}

.include <bsd.port.mk>
