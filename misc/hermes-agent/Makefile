PORTNAME=	hermes-agent
PORTVERSION=	0.22.5
CATEGORIES=	misc python
MASTER_SITES=	LOCAL/olivier:webdist
DISTFILES=	${_WEBDIST}:webdist

MAINTAINER=	olivier@FreeBSD.org
COMMENT=	AI agent with built-in learning loop
WWW=		https://github.com/NousResearch/hermes-agent

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

# Upstream keeps a small `dependencies` core in pyproject.toml plus extras
# that the bundled pm/ package manager (uv-backed) installs on first use.
# pkg owns site-packages so patch-pm_install.py turns that off on FreeBSD,
# and the extras we want (anthropic, edge-tts, exa-py, fal-client,
# firecrawl-py, parallel-web, the [web] dashboard) are listed here as hard
# RUN_DEPENDS instead.
#
# firecrawl-anydoc (core upstream) is deliberately missing: no port exists,
# and tools/read_extract.py guards the import, so only the legacy-Office /
# ODF / EPUB read_file paths degrade.
RUN_DEPENDS=	${PYTHON_PKGNAMEPREFIX}anthropic>=0.87.0:misc/py-anthropic@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}certifi>=2026.5.20:security/py-certifi@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}croniter>=6.0.0:sysutils/py-croniter@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}cryptography>=50.0.1:security/py-cryptography@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}edge-tts>=7.2.7:audio/py-edge-tts@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}exa-py>=2.10.2:www/py-exa-py@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}fal-client>=0.13.1:misc/py-fal-client@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}fastapi>=0.133.1:www/py-fastapi@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}fire>=0.7.1:devel/py-fire@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}firecrawl-py>=4.17.0:www/py-firecrawl-py@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}httptools>=0.6.3:www/py-httptools@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}httpx>=0.28.1:www/py-httpx@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}Jinja2>=3.1.6:devel/py-Jinja2@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}markdown>=3.10.2:textproc/py-markdown@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}openai>=2.24.0:misc/py-openai@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}packaging>=26.0:devel/py-packaging@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}parallel-web>=0.4.2:www/py-parallel-web@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pathspec>=1.1.1:devel/py-pathspec@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pillow-heif>=1.4.0:graphics/py-pillow-heif@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pillow>=12.3.0:graphics/py-pillow@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}prompt-toolkit>=3.0.52:devel/py-prompt-toolkit@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}psutil>=7.2.2:sysutils/py-psutil@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}ptyprocess>=0.7.0:sysutils/py-ptyprocess@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pydantic2>=2.13.4:devel/py-pydantic2@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pyjwt>=2.14.0:www/py-pyjwt@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pysocks>0:net/py-pysocks@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}python-dotenv>=1.2.2:www/py-python-dotenv@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}python-multipart>=0.0.32:www/py-python-multipart@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pyyaml>=6.0.3:devel/py-pyyaml@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}requests>=2.33.0:www/py-requests@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}rich>=14.3.3:textproc/py-rich@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}ruamel.yaml>=0.18.17:devel/py-ruamel.yaml@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}snowballstemmer>=3.1.1:textproc/py-snowballstemmer@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}socksio>0:net/py-socksio@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}starlette>=1.3.1:www/py-starlette@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}tenacity>=9.1.4:devel/py-tenacity@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}tomli-w>=1.2.0:textproc/py-tomli-w@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}truststore>=0.10.4:security/py-truststore@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}urllib3>=2.8.0:net/py-urllib3@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}uvicorn>=0.41.0:www/py-uvicorn@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}watchfiles>=0.20:devel/py-watchfiles@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}websockets>=15.0.1:devel/py-websockets@${PY_FLAVOR}

USES=		python:3.11+ shebangfix
USE_GITHUB=	yes
GH_ACCOUNT=	NousResearch
GH_TAGNAME=	v0.22.5
USE_RC_SUBR=	hermes_dashboard hermes_gateway
SHEBANG_FILES=	*.py

NO_ARCH=	yes
NO_BUILD=	yes
SUB_FILES=	pkg-message

PLIST_FILES=	bin/hermes \
		bin/hermes-acp \
		bin/hermes-agent
PORTDOCS=	AGENTS.md CONTRIBUTING.md README.md SECURITY.md

OPTIONS_DEFINE=	DOCS

# How to update
#
# 1. Set PORTVERSION and GH_TAGNAME from the upstream release.  Leave
#    _WEBDIST_SUFFIX empty, unless a web bundle for this PORTVERSION has
#    already been published, in which case set it to -1, -2, ... so the new
#    archive gets a name the mirrors have not seen.
# 2. Compare upstream pyproject.toml `dependencies` and the extras listed
#    above with RUN_DEPENDS, and the top-level directories holding an
#    __init__.py (ignoring evals/ and tests/) with HERMES_PKGS.
# 3. make _webdist
#    Builds the web dashboard bundle from the new upstream tarball, writes
#    ${_WEBDIST} into ${DISTDIR} and runs makesum.  Needs network access
#    and www/npm with node 22 or newer; the upstream root package-lock.json
#    pins every npm package, so the result is reproducible.  The root is an
#    npm workspaces monorepo; --ignore-scripts skips the ui-tui node-pty and
#    electron downloads the dashboard does not need.  As of 0.22.5 the build
#    trips TS18048 in web/vite.config.ts under the pinned typescript 6:
#    rewrite `preset.rolldown.filter.code = /re/;` as
#    `preset.rolldown.filter = { ...preset.rolldown.filter, code: /re/ };`
#    in ${_WEBSRC} if it still does.  Only works on
#    amd64, because the native npm packages the build needs (tailwind
#    oxide, lightningcss, rolldown) are published for freebsd-x64 only.
#    The bundle itself is plain HTML/CSS/JS, so the port stays NO_ARCH.
# 4. make _upload
#    Copies the archive to your public_distfiles/ on freefall.  Adjust
#    MASTER_SITES if your LOCAL/ directory is not olivier.
# 5. Test build, commit.

_WEBDIST_SUFFIX=
_WEBDIST_DIR=	${PORTNAME}-web-dist-${PORTVERSION}${_WEBDIST_SUFFIX}
_WEBDIST=	${_WEBDIST_DIR}${EXTRACT_SUFX}
_WEBSRC=	${WRKDIR}/websrc
_GH_DISTFILE=	${DISTNAME}${EXTRACT_SUFX}

# Hermes is an application, not a library: it ships top-level packages with
# generic names (tools, agent, gateway, plugins, ...) and bare modules
# (cli.py, utils.py, ...) that would collide in site-packages.  Like
# upstream's Docker, Nix and Homebrew packaging we install the tree into a
# private directory and put thin wrappers in bin/ that prepend it to
# sys.path.
HERMES_LIBDIR=	${PREFIX}/lib/${PORTNAME}

# Top-level packages to install.  The bare top-level *.py modules are not
# listed, do-install globs them, because upstream adds new ones most
# releases.  evals/ and tests/ are dev-only and excluded on purpose.
HERMES_PKGS=	acp_adapter agent cron gateway hermes_cli hermes_platform \
		plugins pm providers tools tui_gateway

# bin/<wrapper>:<python module whose main() it calls>
_ENTRYPOINTS=	hermes:hermes_cli.main hermes-agent:run_agent \
		hermes-acp:acp_adapter.entry

# web_server.py serves the dashboard from hermes_cli/web_dist next to
# itself, so put the prebuilt bundle there before do-install copies the tree.
post-extract:
	${MV} ${WRKDIR}/${_WEBDIST_DIR} ${WRKSRC}/hermes_cli/web_dist

# FreeBSD rc.d service backend.  Upstream has one gateway_<platform>.py per
# service manager; ours is a new file rather than a patch because patch(1)
# cannot create one.  patch-hermes__cli_gateway.py wires it in.
post-patch:
	${INSTALL_DATA} ${FILESDIR}/gateway_freebsd.py \
		${WRKSRC}/hermes_cli/gateway_freebsd.py

do-install:
	${MKDIR} ${STAGEDIR}${HERMES_LIBDIR} ${STAGEDIR}${DATADIR}
.for d in ${HERMES_PKGS}
	cd ${WRKSRC} && ${COPYTREE_SHARE} ${d} ${STAGEDIR}${HERMES_LIBDIR} \
		"! -name __pycache__ ! -name *.pyc"
.endfor
	cd ${WRKSRC} && for f in *.py; do \
		[ "$$f" = setup.py ] && continue; \
		${INSTALL_DATA} $$f ${STAGEDIR}${HERMES_LIBDIR}; \
	done
.for e in ${_ENTRYPOINTS}
	${SED} -e 's|%%HERMES_LIBDIR%%|${HERMES_LIBDIR}|g' \
		-e 's|%%DATADIR%%|${DATADIR}|g' \
		-e 's|%%PYTHON_CMD%%|${PYTHON_CMD}|g' \
		-e 's|%%ENTRY_MODULE%%|${e:C/.*://}|g' \
		${FILESDIR}/wrapper.in > ${STAGEDIR}${PREFIX}/bin/${e:C/:.*//}
	${CHMOD} ${BINMODE} ${STAGEDIR}${PREFIX}/bin/${e:C/:.*//}
.endfor
# Since 0.22.5 the version comes from install-stamp.json beside pm/;
# without it hermes reports 0.0.0.  GIT_DIR keeps the script from
# reading the ports tree's git state when WRKDIR is inside it.
	cd ${WRKSRC} && ${SETENV} GIT_DIR=/nonexistent ${PYTHON_CMD} \
		scripts/write_install_stamp.py \
		-o ${STAGEDIR}${HERMES_LIBDIR}/install-stamp.json \
		--commit ${GH_TAGNAME} --base-version ${PORTVERSION} \
		--distance 0 --source freebsd-ports --update-mechanism external
	cd ${WRKSRC} && ${COPYTREE_SHARE} "skills optional-skills" \
		${STAGEDIR}${DATADIR}

post-install:
	@cd ${STAGEDIR}${PREFIX} && ${FIND} -s \
		${HERMES_LIBDIR:S,^${PREFIX}/,,} ${DATADIR:S,^${PREFIX}/,,} \
		-type f >> ${TMPPLIST}

post-install-DOCS-on:
	${MKDIR} ${STAGEDIR}${DOCSDIR}
.for f in ${PORTDOCS}
	${INSTALL_DATA} ${WRKSRC}/${f} ${STAGEDIR}${DOCSDIR}
.endfor

# Maintainer targets, see "How to update" above.
_webdist:
	@if [ -f ${_DISTDIR}/${_WEBDIST} ]; then \
		${ECHO_MSG} "===> ${_WEBDIST} already exists; set _WEBDIST_SUFFIX before rebuilding it"; \
		exit 1; \
	fi
	cd ${.CURDIR} && ${MAKE} fetch DISTFILES=${_GH_DISTFILE}
	${RM} -r ${_WEBSRC} ${WRKDIR}/${_WEBDIST_DIR}
	${MKDIR} ${_WEBSRC}
	${TAR} -xf ${_DISTDIR}/${_GH_DISTFILE} --strip-components 1 -C ${_WEBSRC}
	cd ${_WEBSRC} && ${SETENV} HOME=${_WEBSRC} npm_config_update_notifier=false \
		npm ci --workspace web --ignore-scripts --no-audit --no-fund
	cd ${_WEBSRC} && ${SETENV} HOME=${_WEBSRC} npm run build --workspace web
	${MV} ${_WEBSRC}/hermes_cli/web_dist ${WRKDIR}/${_WEBDIST_DIR}
	${TAR} --no-acls --no-xattrs --no-fflags --uid=0 --gid=0 \
		-czf ${_DISTDIR}/${_WEBDIST} -C ${WRKDIR} ${_WEBDIST_DIR}
	cd ${.CURDIR} && ${MAKE} makesum
	@${ECHO_MSG} "===> distinfo updated; run \"make _upload\" to publish ${_WEBDIST}"

_upload:
	rsync -Phriv --times --chmod=F644 ${_DISTDIR}/${_WEBDIST} \
		freefall.freebsd.org:public_distfiles/

.include <bsd.port.mk>
