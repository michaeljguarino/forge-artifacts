{{ $hostname := default "example.com" .Values.hostname }}
argo-cd:
  server:
    certificate:
      domain: {{ $hostname }}
    ingress:
      hosts:
        - {{ $hostname }}
      tls:
        - secretName: argocd-server-tls
          hosts:
            - {{ $hostname }}
    config:
      url: https://{{ $hostname }}
