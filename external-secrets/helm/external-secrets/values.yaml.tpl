{{- if eq .Provider "aws" }}
external-secrets:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::{{ .Project }}:role/{{ .Cluster }}-external-secrets"
{{- end }}
{{- if eq .Provider "aws" }}
clusterSecretStore:
  provider:
    aws:
      service: SecretsManager
      region: {{ .Region }}
{{- end }}
