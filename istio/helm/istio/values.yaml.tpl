istio-operator:
  operatorNamespace: {{ namespace "istio" }}
  watchedNamespaces: {{ namespace "istio" }}
istio:
  namespace: {{ namespace "istio" }}

provider: {{ .Provider }}

{{ $bootstrapNamespace := namespace "bootstrap" }}
{{ $grafanaNamespace := namespace "grafana" }}
{{ $grafanaCreds := secret $grafanaNamespace "grafana-credentials" }}
monitoring:
  namespace: {{ $bootstrapNamespace }}
  grafama:
    namespace: {{ $grafanaNamespace }}

kiali-server:
  namespace: {{ namespace "istio" }}
  istio_namespace: {{ namespace "istio" }}
  external_services:
    prometheus:
      url: http://bootstrap-prometheus.{{ $bootstrapNamespace }}:9090
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
