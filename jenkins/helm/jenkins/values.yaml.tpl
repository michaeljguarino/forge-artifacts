{{ $hostname := default "example.com" .Values.hostname }}
global:
  application:
    links:
    - description: jenkins instance
      url: {{ $hostname }}

jenkins:
  controller:
    ingress:
      hostName: {{ $hostname }}
      tls:
      - secretName: jenkins-tls
        hosts:
          - {{ $hostname }}
