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
  {{ if .OIDC }}
      oidc.config: |
        name: Plural
        issuer: {{ .OIDC.Configuration.Issuer }}
        clientID: {{ .OIDC.ClientId }}
        clientSecret: $CLIENT_SECRET
        requestedScopes: ["openid", "profile"]
  configs:
    secret:
      extra:
        CLIENT_SECRET: {{ .OIDC.ClientSecret | b64enc }}
  dex:
    enabled: false
  {{ end }}
