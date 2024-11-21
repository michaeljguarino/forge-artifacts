{{- if eq .Provider "aws" }}
gateway:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-name: {{ .Cluster }}-istio-nlb
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
{{- end }}

provider: {{ .Provider }}

istioGateway:
  hosts:
  - {{ .Network.Subdomain }}
  - "*.{{ .Network.Subdomain }}"
  tls:
    commonName: {{ .Network.Subdomain }}
    dnsNames:
    - {{ .Network.Subdomain }}
    - "*.{{ .Network.Subdomain }}"
