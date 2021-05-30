# Created by: Bartek Rutkowski <robak@FreeBSD.org>
# $FreeBSD$

PORTNAME=	nginx
PKGNAMESUFFIX=	-rtmp

MAINTAINER=	robak@FreeBSD.org
COMMENT=	Robust and small WWW server (real-time streaming media package)

MASTERDIR=	${.CURDIR}/../nginx

CONFLICTS=	nginx-1.* \
		nginx-devel-1.* \
                nginx-full-1.* \
                nginx-naxsi-1.*

OPTIONS_DEFAULT=FILE_AIO HTTP HTTP_CACHE \
		HTTP_REALIP HTTP_REWRITE \
		HTTP_SSL THREADS \
		RTMP

.include "${MASTERDIR}/Makefile"
