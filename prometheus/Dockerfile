FROM prom/prometheus:v2.47.1
RUN mkdir -p /etc/prometheus && \
    mkdir -p /prometheus
COPY prometheus.yml /etc/prometheus/prometheus.yml
RUN chown -R nobody:nobody /etc/prometheus /prometheus
EXPOSE 9090
VOLUME [ "/prometheus" ]
CMD [ "--config.file=/etc/prometheus/prometheus.yml", \
      "--storage.tsdb.path=/prometheus", \
      "--web.console.libraries=/usr/share/prometheus/console_libraries", \
      "--web.console.templates=/usr/share/prometheus/consoles" ]
