PORTNAME=	hedgedoc
DISTVERSION=	1.9.6
CATEGORIES=	www editors
MASTER_SITES=	https://github.com/${PORTNAME}/${PORTNAME}/releases/download/${DISTVERSION}/ \
		https://nodejs.org/download/release/v${NODEJS_VERSION}/:node \
		LOCAL/dch:yarn
DISTFILES+=	${PORTNAME}-${DISTVERSION}${EXTRACT_SUFX} \
		${_YARN_TARBALL}:yarn \
		node-v${NODEJS_VERSION}-headers.tar.gz:node

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Web-based online markdown doc editor backed by SQLite
WWW=		https://hedgedoc.org/

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		python:build shebangfix nodejs:16,run,build

USE_RC_SUBR=	${PORTNAME}
OPTIONS_SUB=	yes

SHEBANG_FILES=	${WRKSRC}/bin/*

NODEJS_VERSION=	16.19.0

BUILD_DEPENDS=	git:devel/git \
		npm:www/npm-node16 \
		sqlite3:databases/sqlite3 \
		yarn:www/yarn-node16
PORTSCOUT=	site:https://github.com/${PORTNAME}/${PORTNAME}/releases

OPTIONS_DEFINE=	DOCS

_YARNRC=	${_YARN_HOME}/yarnrc
_YARN_BIN=	${LOCALBASE}/bin/yarn
_YARN_CACHE=	${_YARN_HOME}/.cache
_YARN_CMD=	${SETENV} ${_YARN_ENV} ${_YARN_BIN} ${_YARN_FLAGS}
_YARN_CWD=	${WRKSRC}
_YARN_ENV=	HOME=${_YARN_HOME} NODE_ENV=production \
		NPM_CONFIG_TARBALL=${DISTDIR}/node-v${NODEJS_VERSION}-headers.tar.gz \
		PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true PYTHON=${PYTHON_CMD}
_YARN_FLAGS=	--skip-integrity-check --noninteractive --no-node-version-check \
		--no-default-rc --cwd ${_YARN_CWD} --cache-folder \
		${_YARN_CACHE} --use-yarnrc ${_YARNRC} --no-progress \
		--frozen-lockfile
_YARN_HOME=	${WRKDIR}/yarn
_YARN_MIRROR=	${_YARN_HOME}/mirror
_YARN_TARBALL=	${DISTNAME}-yarn-cache.txz

tarball: patch
	(cd ${WRKSRC} && \
		${_YARN_CMD} --ignore-scripts)
	(cd ${WRKDIR} && \
		${TAR} cvaf ${_YARN_TARBALL} yarn/mirror)
	rsync -Phivl --inplace ${WRKDIR}/${_YARN_TARBALL} freefall:public_distfiles/

post-extract:
	@${MV} ${WRKDIR}/${PORTNAME} \
		${WRKSRC}

post-patch:
	@${MKDIR} ${_YARN_MIRROR}
	@${ECHO_CMD} 'yarn-offline-mirror "${_YARN_MIRROR}"' > ${_YARNRC}

do-build:
	(cd ${WRKSRC} && \
		${_YARN_CMD} --offline install)
	(cd ${WRKSRC} && ${RM} -r \
		${WRKSRC}/node_modules/prebuilds/ \
		${WRKSRC}/node_modules/sqlite3/build-tmp-napi-v6 \
		renovate.json test webpack.*)
	pwd -P
	echo ${STRIP_CMD} $(${FIND} ${WRKSRC}/node_modules -name '*node')

do-install:
	${MKDIR} ${STAGEDIR}${ETCDIR} \
		${STAGEDIR}${DOCSDIR} \
		${STAGEDIR}${PREFIX}/libexec/${PORTNAME}/bin \
		${STAGEDIR}/var/db/hedgedoc
	(cd ${WRKSRC} && \
		${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/libexec/${PORTNAME})
	(cd ${WRKSRC} && \
		${COPYTREE_BIN} bin ${STAGEDIR}${PREFIX}/libexec/${PORTNAME})
	(cd ${WRKSRC}/docs && \
		${COPYTREE_SHARE} . ${STAGEDIR}${DOCSDIR})
	${INSTALL_DATA} ${WRKSRC}/config.json.example \
		${STAGEDIR}${ETCDIR}/config.json.sample

.include <bsd.port.mk>
