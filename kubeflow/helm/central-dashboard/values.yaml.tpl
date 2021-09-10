{{ $istioNamespace := namespace "istio" }}
{{ $hostname := default "kubeflow.kubeflow-aws.com" .Values.hostname }}
global:
  istioNamespace: {{ $istioNamespace }}
  domain: {{ $hostname }}
