{{/*
Expand the name of the chart.
*/}}
{{- define "gateway-plural.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway-plural.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateway-plural.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gateway-plural.labels" -}}
helm.sh/chart: {{ include "gateway-plural.chart" . }}
{{ include "gateway-plural.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gateway-plural.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway-plural.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gateway-plural.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gateway-plural.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the hmac secret for oauth2
*/}}
{{- define "gateway-plural.hmacResource" -}}
resources:
- "@type": "type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.Secret"
  name: hmac
  generic_secret:
    secret:
      inline_string: {{ .Values.oidc.hmacSecret }}
{{- end }}

{{/*
Create the client (token) secret for oauth2
*/}}
{{- define "gateway-plural.clientSecretResource" -}}
resources:
- "@type": "type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.Secret"
  name: token
  generic_secret:
    secret:
      inline_string: {{ .Values.oidc.clientSecret }}
{{- end }}
