PORTNAME=	tidewave-app
DISTVERSIONPREFIX=	v
DISTVERSION=	1.1.0
CATEGORIES=	deskutils

MAINTAINER=	dch@FreeBSD.org
COMMENT=	Desktop app for the Tidewave coding agent
WWW=		https://tidewave.ai/

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

LIB_DEPENDS=	libdbus-1.so:devel/dbus \
		libsoup-3.0.so:devel/libsoup3 \
		libwebkit2gtk-4.1.so:www/webkit2-gtk@41 \
		libzstd.so:archivers/zstd
# tray-icon dlopen()s libayatana-appindicator3, so it is not linked against.
# xdg-open and xdg-mime are used to open the browser, config file and logs.
# claude-agent-acp is what the client spawns to talk to Claude Code; the
# client cannot download it itself on FreeBSD, so /shell-env points at it.
RUN_DEPENDS=	claude-agent-acp:misc/claude-agent-acp \
		libayatana-appindicator>0:devel/libayatana-appindicator \
		xdg-open:devel/xdg-utils

# ssl is needed so that cargo.mk points openssl-sys at the right OpenSSL;
# with the base provider it adds no dependency, hence the stage-qa notice.
USES=		cargo gnome pkgconfig ssl xorg
USE_GITHUB=	yes
GH_ACCOUNT=	tidewave-ai
GH_PROJECT=	tidewave_app
USE_GNOME=	cairo gdkpixbuf glib20 gtk30
USE_XORG=	x11

# The workspace also contains tidewave-cli, which is packaged separately as
# www/tidewave-cli; build and install only the desktop app here.
CARGO_BUILD_ARGS=	--package tidewave-app
CARGO_INSTALL_PATH=	src-tauri

DESKTOP_ENTRIES=	"Tidewave IDE" \
			"${COMMENT}" \
			"${PORTNAME}" \
			"tidewave-app" \
			"Development;IDE;" \
			${FALSE}

_ICON_SIZES=	32x32 64x64 128x128 256x256

PLIST_FILES=	${_ICON_SIZES:S,^,share/icons/hicolor/,:S,$,/apps/${PORTNAME}.png,} \
		bin/tidewave-app

post-install:
.for size in ${_ICON_SIZES}
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/${size}/apps
	${INSTALL_DATA} ${WRKSRC}/src-tauri/icons/${size}.png \
		${STAGEDIR}${PREFIX}/share/icons/hicolor/${size}/apps/${PORTNAME}.png
.endfor

.include <bsd.port.mk>
