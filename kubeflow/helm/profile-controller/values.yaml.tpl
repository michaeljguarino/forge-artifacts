{{- $argocdNamespace := namespace "argo-cd" -}}
{{- $knativeNamespace := namespace "knative" -}}

global:
  {{- if .OIDC }}
  oidc:
    issuer: {{ .OIDC.Configuration.Issuer }}
    jwksURI: {{ .OIDC.Configuration.JwksUri }}
    authEndpoint: {{ .OIDC.Configuration.AuthorizationEndpoint }}
    tokenEndpoint: {{ .OIDC.Configuration.TokenEndpoint }}
  {{- end }}

kfam:
  adminEmail: {{ .Config.Email }}
  secret:
    argoToken: {{ dedupe . "profile-controller.kfam.secret.argoToken" (randAlphaNum 32) }}

argocd:
  namespace: {{ $argocdNamespace }}

knative:
  namespace: {{ $knativeNamespace }}

config:
  infrastructure:
    clusterName: {{ .Cluster }}
    {{- if eq .Provider "google"}}
    provider: GCP
    {{- else }}
    provider: {{ upper .Provider }}
    {{ end }}
    providerConfig:
      accountID: {{ .Project | quote }}
      region: {{ .Region }}
    {{ if eq .Provider "aws" }}
      clusterOIDCIssuer: {{ importValue "Terraform" "oidc_issuer_url" }}
    {{- end }}
    storage:
      provider: S3
      bucketName: {{ .Values.pipelines_bucket }}
  network:
    hostname: {{ .Values.hostname }}
  security:
    oidc:
      issuer: https://oidc.plural.sh/
      jwksURI: https://oidc.plural.sh/.well-known/jwks.json
