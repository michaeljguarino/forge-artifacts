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
        clientSecret: $oidc.plural.clientSecret
        requestedScopes: ["openid", "profile"]
        requestedIDTokenClaims:
          email:
            essential: true
          groups:
            essential: true
  configs:
    secret:
      extra:
        oidc.plural.clientSecret: {{ .OIDC.ClientSecret }}
  dex:
    enabled: false
  {{ end }}
