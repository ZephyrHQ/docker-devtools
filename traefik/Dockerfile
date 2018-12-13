FROM traefik:alpine

LABEL maintainer="Derivery Damien <damien.derivery@gmail.com>"

ARG SELFSIGNED_CERTS
ENV SELFSIGNED_CERTS ${SELFSIGNED_CERTS}

RUN if [[ ${SELFSIGNED_CERTS} = 1 ]]; then \
        # Install necessary libraries
        apk --update add --no-cache --virtual .persistent-deps ca-certificates openssl \
        && rm -f /var/cache/apk/*; \
    fi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
