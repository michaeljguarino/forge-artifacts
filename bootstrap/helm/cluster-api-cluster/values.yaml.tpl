provider: {{ .Provider }}
cluster:
  name: {{ .Cluster }}

  {{ if eq .Provider "aws" }}
  kubernetesVersion: v1.24
  aws:
    region: {{ .Region }}
    iamAuthenticatorConfig:
      mapRoles:
      - rolearn: "arn:aws:iam::{{ .Project }}:role/{{ .Cluster }}-capa-controller"
        username: capa-admin
        groups:
        - system:masters
  {{ end }}

  {{ if eq .Provider "azure" }}
  kubernetesVersion: 1.24.10
  azure:
    clientID: {{ .Context.ClientId }}
    clientSecret: {{ .Context.ClientSecret }}
    tenantID: {{ .Context.TenantId }}
    subscriptionID: {{ .Context.SubscriptionId }}
    location: {{ .Region }}
    resourceGroupName: {{ .Project }}
  {{ end }}

  {{ if eq .Provider "google" }}
  kubernetesVersion: 1.24.11-gke.1000
  google:
    project: {{ .Project }}
    region: {{ .Region }}
  {{ end }}
