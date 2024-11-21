
{{- if .Configuration.kubeflow }}
knative-serving:
  configDomain:
    data:
      {{ .Configuration.kubeflow.hostname }}: ""
  net-istio:
    configIstio:
      data:
        gateway.kubeflow.kubeflow-gateway: istio-ingress.istio-ingress.svc.cluster.local
        local-gateway.knative.knative-local-gateway: "knative-local-gateway.istio-ingress.svc.cluster.local"
    istio:
      namespace: istio-ingress
      ingressGateway:
        create: false
      localGateway:
        selector:
          istio: ingress
kubeflow:
  enabled: true
{{- end }}
