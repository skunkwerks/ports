PORTNAME=	tidewave-cli
DISTVERSIONPREFIX=	v
DISTVERSION=	1.1.0-2
CATEGORIES=	www

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Command line interface for the Tidewave coding agent
WWW=		https://tidewave.ai/

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

LIB_DEPENDS=	libzstd.so:archivers/zstd
# xdg-open opens files and directories from the browser.
# claude-agent-acp is what the server spawns to talk to Claude Code; it
# cannot download it itself on FreeBSD, so /shell-env points at the port.
RUN_DEPENDS=	claude-agent-acp:misc/claude-agent-acp \
		xdg-open:devel/xdg-utils

# ssl is needed so that cargo.mk points openssl-sys at the right OpenSSL;
# with the base provider it adds no dependency, hence the stage-qa notice.
USES=		cargo ssl
USE_GITHUB=	yes
GH_ACCOUNT=	tidewave-ai
GH_PROJECT=	tidewave_app
GH_TAGNAME=	2e72d9b

# The upstream workspace also contains the Tauri desktop app, which is
# packaged separately as deskutils/tidewave-app.  It is dropped from the
# workspace members by a patch so that the whole GTK/WebKit dependency
# graph stays out of this port.
CARGO_INSTALL_PATH=	tidewave-cli

PLIST_FILES=	bin/tidewave

.include <bsd.port.mk>
