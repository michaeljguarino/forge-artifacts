{{ $hostname := default "example.com" .Values.hostname }}
argo-cd:
  server:
    certificate:
      domain: {{ $hostname }}
    ingress:
      hosts:
        - {{ $hostname }}
      tls:
        - hosts:
            - {{ $hostname }}
    config:
      url: https://{{ $hostname }}
