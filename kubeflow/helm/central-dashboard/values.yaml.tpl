{{- $hostname := .Values.hostname -}}
{{- $monitoringNamespace := namespace "monitoring" -}}

global:
  application:
    links:
    - description: kubeflow dashboard ui
      url: {{ $hostname }}
  domain: {{ $hostname }}

{{- if chartInstalled "monitoring" "monitoring" }}
config:
  prometheusURL: http://monitoring-prometheus.{{ $monitoringNamespace }}:9090
{{- end }}
