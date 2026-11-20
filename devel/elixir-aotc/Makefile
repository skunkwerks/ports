PORTNAME=	elixir-aotc
DISTVERSION=	0.1.20260909
CATEGORIES=	devel
MASTER_SITES+=	https://builds.hex.pm/installs/1.20.0/:hex
DISTFILES+=	hex-${_HEXPM_VERSION}-otp-${_HEXPM_OTP}.ez:hex

MAINTAINER=	erlang@FreeBSD.org
COMMENT=	Compile Elixir scripts to self-contained native executables
WWW=		https://github.com/wojtekmach/elixiraotc

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE.txt

BUILD_DEPENDS=	${OPENSSLBASE}/lib/libcrypto.a:security/openssl \
		elixir:lang/elixir-devel

# Single-binary "elixiraotc" tool, reproduced from the upstream CI workflow
# The port pins erlang/otp to the commit the CI uses (OTP 29.0.3-era)
# Apply the additional out-of-tree erlaotc/AOT patches (files/patch-otp-*)
# Build a fully static JIT-enabled emulator
# Embed lang/elixir-devel port as BEAM bytecode is forward-compatible
USES=		gmake ncurses perl5 ssl:build

USE_GITHUB=	yes
GH_ACCOUNT=	erlang
GH_PROJECT=	otp
GH_TAGNAME=	e617ca67168c5e13ce7691801cbe07a7b8aeb058
USE_PERL5=	build

# The static NIF link needs a -fPIC libcrypto.a. Use ports/security/openssl
# as base /usr/lib/libcrypto.a is non-PIC
DEFAULT_VERSIONS+=	ssl=openssl

# Static, JIT-enabled emulator
GNU_CONFIGURE=	yes
CONFIGURE_ARGS=	--disable-dynamic-ssl-lib \
		--enable-builtin-zlib \
		--enable-jit \
		--enable-static-nifs \
		--with-ssl=${OPENSSLBASE} \
		--without-debugger \
		--without-diameter \
		--without-et \
		--without-javac \
		--without-jinterface \
		--without-megaco \
		--without-observer \
		--without-odbc \
		--without-snmp \
		--without-wx
# Force the ports libcrypto, not base
CONFIGURE_ENV=	LIBS=${OPENSSLBASE}/lib/libcrypto.a

MAKE_ENV+=	ERL_TOP=${WRKSRC} \
		PATH=${WRKSRC}/bin:${PATH}

# The three patched preloaded modules (erl_prim_loader, init, prim_zip) are
# committed upstream as precompiled, stripped .beam files and are not rebuilt
# by a normal `make`.
#
# They are regenerated here from their patched .erl sources using the
# freshly built erlc, so no byte blobs are shipped. This is the same
# pipeline as erts/preloaded/src/Makefile's `copy` target:
#   erlc -> .beam (IFF "FOR1")  ->  beam_lib:strip -> zlib:gunzip
PRELOAD_MODULES=	erl_prim_loader init prim_zip

PATCH_STRIP=	-p1
PLIST_FILES=	${EXAMPLESDIR_REL}/hello.exs \
		${EXAMPLESDIR_REL}/nanoid.exs \
		${EXAMPLESDIR_REL}/static_nif/greet.c \
		${EXAMPLESDIR_REL}/static_nif/greet.exs \
		${EXAMPLESDIR_REL}/static_nif/native-c.json \
		${EXAMPLESDIR_REL}/static_nif/native-rust.json \
		${EXAMPLESDIR_REL}/static_nif/native.json \
		${EXAMPLESDIR_REL}/static_nif/README.md \
		${EXAMPLESDIR_REL}/static_nif/rust_greet.exs \
		${EXAMPLESDIR_REL}/static_nif/rust_greet/Cargo.toml \
		${EXAMPLESDIR_REL}/static_nif/rust_greet/src/lib.rs \
		bin/elixiraotc

# The native SDK lets a NIF from an application dependency be linked into the
# emulator statically, so the executable needs no shared library. It is
# exported from the patched OTP build and installed alongside the tool.
NATIVE_SDK_REL=	${PORTNAME}/native-sdk
NATIVE_SDK_DIR=	${WRKDIR}/native-sdk

.include <bsd.port.pre.mk>

_HEXPM_VERSION=	2.5.3
_HEXPM_OTP=	29

CFLAGS+=	-DMAP_NORESERVE=0

do-build:
	@cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${MAKE_CMD} -C lib TARGET=${CONFIGURE_TARGET} \
		BUILD_STATIC_LIBS=1 TYPE=opt static_lib
	@cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_CMD}
	@${MAKE} regenerate-beams
	@cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${MAKE_CMD} -C erts/emulator TARGET=${CONFIGURE_TARGET}
	@${SETENV} ${MAKE_ENV} OTP=${WRKSRC} \
		${LOCALBASE}/bin/elixir ${FILESDIR}/export-native-sdk.exs \
		${WRKSRC} ${NATIVE_SDK_DIR}

regenerate-beams:
	@${MKDIR} ${WRKSRC}/erts/preloaded/ebin
	@for m in ${PRELOAD_MODULES}; do \
		${SETENV} ${MAKE_ENV} ${WRKSRC}/bin/erlc +deterministic \
			-I${WRKSRC}/lib/kernel/src -I${WRKSRC}/lib/kernel/include \
			-o ${WRKDIR} ${WRKSRC}/erts/preloaded/src/$${m}.erl \
		&& ${SETENV} ${MAKE_ENV} ${WRKSRC}/bin/erl -noshell -eval \
			"[begin {ok,Bin}=file:read_file(\"${WRKDIR}/$${m}.beam\"), \
			 {ok,{_,S}}=beam_lib:strip(Bin), \
			 ok=file:write_file(\"${WRKSRC}/erts/preloaded/ebin/$${m}.beam\", zlib:gunzip(S)) \
			 end]." -s init stop; \
	done

post-extract:
	@${MKDIR} ${WRKDIR}/.mix/archives/hex-${_HEXPM_VERSION}
	@${MV} ${WRKDIR}/hex-${_HEXPM_VERSION} \
		${WRKDIR}/.mix/archives/hex-${_HEXPM_VERSION}/

do-install:
	@cd ${WRKSRC}/examples && ${SETENV} ${MAKE_ENV} \
		MIX_HOME=${WRKDIR}/.mix MIX_ARCHIVES=${WRKDIR}/.mix/archives \
		HEX_OFFLINE=true PATH=${WRKSRC}/bin:${PATH} \
		${LOCALBASE}/bin/elixir elixiraotc.exs build elixiraotc.exs \
		--native-sdk ${NATIVE_SDK_DIR}
	${MKDIR} ${STAGEDIR}${PREFIX}/bin
	# Do not strip: the executable appends a zip archive of the embedded
	# runtime to the emulator, and strip(1) truncates that trailing data.
	${INSTALL_PROGRAM:N-s} ${WRKSRC}/examples/elixiraotc \
		${STAGEDIR}${PREFIX}/bin/elixiraotc
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	${INSTALL_DATA} ${FILESDIR}/hello.exs \
		${STAGEDIR}${EXAMPLESDIR}/hello.exs
	${INSTALL_DATA} ${FILESDIR}/nanoid.exs \
		${STAGEDIR}${EXAMPLESDIR}/nanoid.exs
	# C and Rust static-NIF examples, grouped under a subdirectory so the
	# rustler crate keeps its Cargo.toml/src layout.
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}/static_nif
	${INSTALL_DATA} ${FILESDIR}/README.md \
		${STAGEDIR}${EXAMPLESDIR}/static_nif/README.md
	${INSTALL_DATA} ${FILESDIR}/greet.c ${FILESDIR}/greet.exs \
		${FILESDIR}/native-c.json ${FILESDIR}/native.json \
		${STAGEDIR}${EXAMPLESDIR}/static_nif/
	${INSTALL_DATA} ${FILESDIR}/rust_greet.exs \
		${FILESDIR}/native-rust.json \
		${STAGEDIR}${EXAMPLESDIR}/static_nif/
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}/static_nif/rust_greet/src
	${INSTALL_DATA} ${FILESDIR}/rust_greet/Cargo.toml \
		${STAGEDIR}${EXAMPLESDIR}/static_nif/rust_greet/Cargo.toml
	${INSTALL_DATA} ${FILESDIR}/rust_greet/src/lib.rs \
		${STAGEDIR}${EXAMPLESDIR}/static_nif/rust_greet/src/lib.rs
	${MKDIR} ${STAGEDIR}${PREFIX}/share/${NATIVE_SDK_REL}
	cd ${NATIVE_SDK_DIR} && \
		${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/share/${NATIVE_SDK_REL}
	${FIND} ${STAGEDIR}${PREFIX}/share/${NATIVE_SDK_REL} -type d -empty \
		-delete

# Exercise the shipped binary before packing:
# - the dependency-free script (hello.exs) built to a self-contained exe
#   that carries the recorded JITC/atom snapshot and runs offline;
# - a C NIF compiled by the tool itself (--native) and statically linked into
#   a relinked emulator via the embedded SDK;
# - the SDK relink path directly, through load_nif on a nonexistent path.
do-test:
	@${GREP} -aq 'jitc/atoms' ${STAGEDIR}${PREFIX}/bin/elixiraotc
	@! ${STAGEDIR}${PREFIX}/bin/elixiraotc -h 2>&1 | \
		${GREP} -q 'BINDIR is not set'
	@${MKDIR} ${WRKDIR}/test && ${CP} ${FILESDIR}/hello.exs ${WRKDIR}/test/
	@cd ${WRKDIR}/test && \
		${STAGEDIR}${PREFIX}/bin/elixiraotc build hello.exs -o hello
	@${WRKDIR}/test/hello 2>&1 | ${GREP} -q 'hi'
	@${MKDIR} ${WRKDIR}/test/nif && \
		${CP} ${FILESDIR}/greet.c ${FILESDIR}/greet.exs \
			${FILESDIR}/native-c.json ${WRKDIR}/test/nif/
	@cd ${WRKDIR}/test/nif && \
		${STAGEDIR}${PREFIX}/bin/elixiraotc build greet.exs \
			--native native-c.json -o greet
	@${WRKDIR}/test/nif/greet | ${GREP} -q 'hello, elixiraotc!'
	@${SETENV} OTP=${WRKSRC} NATIVE_SDK=${NATIVE_SDK_DIR} \
		${LOCALBASE}/bin/elixir ${FILESDIR}/test-native-sdk.exs

post-stage:
	@cd ${STAGEDIR}${PREFIX}/share/${NATIVE_SDK_REL} && \
		${FIND} . -type f | ${SORT} | \
		${SED} -e 's|^\./|share/${NATIVE_SDK_REL}/|' >> ${TMPPLIST}

.include <bsd.port.post.mk>
