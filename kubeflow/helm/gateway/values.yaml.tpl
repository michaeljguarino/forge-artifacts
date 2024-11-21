{{ $istioNamespace := namespace "istio-ingress" }}
{{ $hostname := .Values.hostname }}

global:
  domain: {{ $hostname }}
  {{- if .OIDC }}
  oidc:
    issuer: {{ .OIDC.Configuration.Issuer }}
    jwksURI: {{ .OIDC.Configuration.JwksUri }}
    authEndpoint: {{ .OIDC.Configuration.AuthorizationEndpoint }}
    tokenEndpoint: {{ .OIDC.Configuration.TokenEndpoint }}
  {{- end }}

{{- if eq .Provider "aws" }}
gateway:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-name: {{ .Cluster }}-kubeflow-nlb
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
{{- end }}

{{- if .OIDC }}
oidc:
  clientID: {{ .OIDC.ClientId }}
  clientSecret: {{ .OIDC.ClientSecret }}
  hmacSecret: {{ dedupe . "gateway.oidc.hmacSecret" (randAlphaNum 32) }}
{{- end }}
