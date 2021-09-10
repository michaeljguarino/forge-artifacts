{{ $istioNamespace := namespace "istio" }}
global:
  istioNamespace: {{ $istioNamespace }}
  domain: {{ $hostname := default "kubeflow.kubeflow-aws.com" .Values.hostname }}
