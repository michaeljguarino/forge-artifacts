{{- $tfOutput := pathJoin repoRoot "bootstrap" "output.yaml" }}
gcp_project_id = {{ .Project | quote }}
cluster_name = {{ .Cluster | quote }}
vpc_name_prefix = {{ .Values.vpc_name | quote }}
externaldns_sa_name = "{{ .Cluster }}-externaldns"
gcp_region = {{ .Region | quote }}
{{- if .ClusterAPI }}
cluster_api = {{ .ClusterAPI }}
{{- end }}
{{- if fileExists $tfOutput }}
{{- $bootstrapOutputs := .Applications.TerraformValues "bootstrap" }}
{{- if and $bootstrapOutputs (not .ClusterAPI) }}
network_policy_enabled = {{ $bootstrapOutputs.cluster.network_policy_enabled }}
{{- if eq $bootstrapOutputs.cluster.datapath_provider "" }}
datapath_provider = "DATAPATH_PROVIDER_UNSPECIFIED"
{{- else }}
datapath_provider = {{ $bootstrapOutputs.cluster.datapath_provider | quote }}
{{- end }}
{{- else }}
network_policy_enabled = false
datapath_provider = "ADVANCED_DATAPATH"
{{- end }}
{{- else }}
network_policy_enabled = false
datapath_provider = "ADVANCED_DATAPATH"
{{- end }}
