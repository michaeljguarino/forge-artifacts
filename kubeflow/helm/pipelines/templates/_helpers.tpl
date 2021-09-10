{{/*
Expand the name of the chart.
*/}}
{{- define "pipelines.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pipelines.fullname" -}}
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
{{- define "pipelines.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pipelines.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pipelines.selectorLabels" -}}
app: {{ include "pipelines.name" . }}
app.kubernetes.io/name: {{ include "pipelines.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
API Server selector labels
*/}}
{{- define "pipelines.apiServerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-api
app.kubernetes.io/name: {{ include "pipelines.name" . }}-api
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Argo Workflow Controller selector labels
*/}}
{{- define "pipelines.argoWorkflowControllerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-argo
app.kubernetes.io/name: {{ include "pipelines.name" . }}-argo
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Cache Server selector labels
*/}}
{{- define "pipelines.cacheServerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-cache-server
app.kubernetes.io/name: {{ include "pipelines.name" . }}-cache-server
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Cache Deployer selector labels
*/}}
{{- define "pipelines.cacheDeployerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-cache-deployer
app.kubernetes.io/name: {{ include "pipelines.name" . }}-cache-deployer
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Container Builder selector labels
*/}}
{{- define "pipelines.containerBuilderSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-container-builder
app.kubernetes.io/name: {{ include "pipelines.name" . }}-container-builder
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Metadata Envoy selector labels
*/}}
{{- define "pipelines.metadataEnvoySelectorLabels" -}}
app: {{ include "pipelines.name" . }}-metadata-envoy
app.kubernetes.io/name: {{ include "pipelines.name" . }}-metadata-envoy
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Metadata Writer selector labels
*/}}
{{- define "pipelines.metadataWriterSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-metadata-writer
app.kubernetes.io/name: {{ include "pipelines.name" . }}-metadata-writer
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Viewer selector labels
*/}}
{{- define "pipelines.viewerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-viewer
app.kubernetes.io/name: {{ include "pipelines.name" . }}-viewer
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Metadata gRPC Server selector labels
*/}}
{{- define "pipelines.metadataGRPCServerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-metadata-grpc-server
app.kubernetes.io/name: {{ include "pipelines.name" . }}-metadata-grpc-server
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Persistence Agent  selector labels
*/}}
{{- define "pipelines.persistenceAgentSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-persistence-agent
app.kubernetes.io/name: {{ include "pipelines.name" . }}-persistence-agent
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Scheduled Workflow  selector labels
*/}}
{{- define "pipelines.scheduledWorkflowSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-scheduled-workflow
app.kubernetes.io/name: {{ include "pipelines.name" . }}-scheduled-workflow
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Viewer Controller  selector labels
*/}}
{{- define "pipelines.viewerControllerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-viewer-controller
app.kubernetes.io/name: {{ include "pipelines.name" . }}-viewer-controller
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Visualization Server  selector labels
*/}}
{{- define "pipelines.visualizationServerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-visualization-server
app.kubernetes.io/name: {{ include "pipelines.name" . }}-visualization-server
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Runner  selector labels
*/}}
{{- define "pipelines.runnerSelectorLabels" -}}
app: {{ include "pipelines.name" . }}-runner
app.kubernetes.io/name: {{ include "pipelines.name" . }}-runner
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pipelines.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pipelines.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
