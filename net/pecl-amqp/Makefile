# Created by: Jui-Nan Lin <jnlin@freebsd.cs.nctu.edu.tw>

PORTNAME=	amqp
PORTVERSION=	1.9.4
PORTREVISION=	1
CATEGORIES=	net pear

MAINTAINER=	jnlin@freebsd.cs.nctu.edu.tw
COMMENT=	PHP extension for AMQP API

LICENSE=	PHP301
LICENSE_FILE=	${WRKSRC}/LICENSE

LIB_DEPENDS=	librabbitmq.so:net/rabbitmq-c

USES=		php:pecl
IGNORE_WITH_PHP=	74 80

.include <bsd.port.mk>
