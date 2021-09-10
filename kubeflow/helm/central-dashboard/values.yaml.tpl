{{ $istioNamespace := namespace "istio" }}
global:
  istioNamespace: {{ $istioNamespace }}
  domain: {{ $hostname := default "kubeflow.kubeflow-aws.com" .Values.hostname }}

mysql-cluster:
  secrets:
    rootPassword: {{ dedupe . "kubeflow.mysql-cluster.secrets.rootPassword" (randAlphaNum 20) }}

katib:
  dbManager:
    dbPassword: {{ dedupe . "kubeflow.katib.secrets.rootPassword" (randAlphaNum 20) }}
