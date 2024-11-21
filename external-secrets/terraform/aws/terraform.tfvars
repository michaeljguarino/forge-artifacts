namespace = {{ .Namespace | quote }}
cluster_name = {{ .Cluster | quote }}
account_id = {{ .Project | quote }}
region = {{ .Region | quote }}
{{- if .Values.extraPolicyARNs }}
extra_policy_arns = {{ toJson .Values.extraPolicyARNs }}
{{- end }}
