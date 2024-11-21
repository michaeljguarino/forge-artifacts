{{ $istioNamespace := namespace "istio-ingress" }}
{{ $knativeNamespace := namespace "knative" }}
{{ $kubeflowNamespace := namespace "kubeflow" }}
kserve:
  kserve:
    controller:
      gateway:
        {{- if .Configuration.kubeflow }}
        domain: {{ .Configuration.kubeflow.hostname }}
        {{- end }}
        localGateway:
          gateway: {{ $knativeNamespace }}/knative-local-gateway
          {{- if .Configuration.kubeflow }}
          gatewayService: knative-local-gateway.{{ $istioNamespace }}.svc.cluster.local
          {{- else }}
          gatewayService: knative-local-gateway.{{ $istioNamespace }}.svc.cluster.local
          {{- end }}
        {{- if .Configuration.kubeflow }}
        ingressGateway:
          gateway: {{ $kubeflowNamespace }}/kubeflow-gateway
          gatewayService: istio-ingress.{{ $istioNamespace }}.svc.cluster.local
        {{- else }}
        ingressGateway:
          gateway: {{ $knativeNamespace }}/knative-ingress-gateway
          gatewayService: istio-ingress.{{ $istioNamespace }}.svc.cluster.local
        {{- end }}
