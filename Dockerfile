FROM alpine
RUN apk update \
  && apk add --no-cache \
  unison \
  rsync \
  bash \
  \
  && rm -rf /var/cache/apk/*

ENV TZ="Europe/Lisbon" \
  LANG="C.UTF-8" \
  UNISON_ETC="/etc/unison" \
  UNISON="/run/unison"

COPY --from=moveyourdigital/wait-for-it /wait-for-it.sh /wait-for-it.sh
COPY default.prf $UNISON_ETC/default.prf
COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh

RUN mkdir -p $UNISON \
  && mkdir -p /docker-entrypoint.d \
  && chmod +x /entrypoint.sh \
  && chmod +x /start.sh

EXPOSE $PORT

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/start.sh" ]
