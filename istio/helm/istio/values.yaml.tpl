istio-operator:
  watchedNamespaces: {{ namespace "istio" }}
istio:
  namespace: {{ namespace "istio" }}

provider: {{ .Provider }}

{{ $monitoringNamespace := namespace "monitoring" }}
{{ $grafanaNamespace := namespace "grafana" }}
{{ $grafanaCreds := secret $grafanaNamespace "grafana-credentials" }}
monitoring:
  namespace: {{ $monitoringNamespace }}
  grafama:
    namespace: {{ $grafanaNamespace }}

kiali-server:
  {{/* {{ if .OIDC }}
  auth:
    strategy: openid
    openid:
      client_id: {{ .OIDC.ClientId }}
      disable_rbac: true
      authentication_timeout: 300
      username_claim: "email"
      client_secret: {{ .OIDC.ClientSecret }}
      issuer_uri: {{ .OIDC.Configuration.Issuer }}
      scopes:
      - "openid"
      - "profile"
  {{ end }} */}}
  deployment:
    override_ingress_yaml:
      metadata:
        annotations:
          kubernetes.io/tls-acme: "true"
          kubernetes.io/ingress.class: "nginx"
          cert-manager.io/cluster-issuer: letsencrypt-prod
          nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
          nginx.ingress.kubernetes.io/use-regex: "true"
      spec:
        tls:
        - hosts:
          - {{ .Values.kialiHostname }}
          secretName: kiali-tls
        rules:
        - host: {{ .Values.kialiHostname }}
          http:
            paths:
            - path: /.*
              pathType: Prefix
              backend:
                service:
                  name: kiali
                  port:
                    name: http
  namespace: {{ namespace "istio" }}
  istio_namespace: {{ namespace "istio" }}
  external_services:
    prometheus:
      url: http://monitoring-prometheus.{{ $monitoringNamespace }}:9090
    grafana:
      auth:
        username: {{ ( index $grafanaCreds "admin-user") }}
        password: {{ ( index $grafanaCreds "admin-password") }}
      url: https://{{ .Configuration.grafana.hostname }}
      in_cluster_url: http://grafana.{{ $grafanaNamespace }}:80
    tracing:
      in_cluster_url: http://istio-jaeger-query.{{ namespace "istio" }}

{{ $oath2proxyNamespace := namespace "oauth2-proxy" }}
oauth2proxy:
  namespace: {{ $oath2proxyNamespace }}
