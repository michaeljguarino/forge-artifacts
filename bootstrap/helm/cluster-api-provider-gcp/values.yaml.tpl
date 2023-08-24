cluster-api-provider-gcp:
  serviceAccount:
    annotations:
      iam.gke.io/gcp-service-account: {{ importValue "Terraform" "capi_sa_workload_identity_email" }}
{{- if .Context.Credentials }}
  managerBootstrapCredentials:
    credentialsJson: {{ .Context.Credentials | quote }}
{{- end }}