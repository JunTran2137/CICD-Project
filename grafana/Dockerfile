FROM grafana/grafana:10.1.2
ENV GF_SECURITY_ADMIN_USER=admin \
    GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_USERS_ALLOW_SIGN_UP=false
RUN mkdir -p /var/lib/grafana && \
    chown -R grafana:grafana /var/lib/grafana
VOLUME ["/var/lib/grafana"]
COPY ./provisioning /etc/grafana/provisioning
EXPOSE 3000
USER grafana
