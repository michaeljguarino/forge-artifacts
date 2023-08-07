{{/*
Expand the name of the chart.
*/}}
{{- define "cluster-api-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cluster-api-cluster.fullname" -}}
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
{{- define "cluster-api-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster-api-cluster.labels" -}}
helm.sh/chart: {{ include "cluster-api-cluster.chart" . }}
{{ include "cluster-api-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cluster-api-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-api-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cluster-api-cluster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cluster-api-cluster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the kind for the infrastructureRef for the cluster
*/}}
{{- define "cluster.infrastructure.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedCluster
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedCluster
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
GCPManagedCluster
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
DockerCluster
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the infrastructureRef for the cluster
*/}}
{{- define "cluster.infrastructure.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the kind for the controlPlaneRef for the cluster
*/}}
{{- define "cluster.controlPlane.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
GCPManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
KubeadmControlPlane
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the controlPlaneRef for the cluster
*/}}
{{- define "cluster.controlPlane.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
controlplane.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
controlplane.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the kind for the infrastructureRef for the worker MachinePools
*/}}
{{- define "workers.infrastructure.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
GCPManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
DockerMachinePool
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the infrastructureRef for the worker MachinePools
*/}}
{{- define "workers.infrastructure.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "google") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the configRef for the worker MachinePools
*/}}
{{- define "workers.configref" -}}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
configRef:
  apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
  kind: KubeadmConfig
  name: worker-mp-config
{{- end }}
{{- end }}