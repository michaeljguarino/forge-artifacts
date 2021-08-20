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
      admin.enabled: "false"
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
    rbacConfig:
      policy.csv: |
        p, role:org-admin, applications, *, */*, allow
        p, role:org-admin, clusters, *, *, allow
        p, role:org-admin, projects, *, *, allow
        p, role:org-admin, certificates, *, *, allow
        p, role:org-admin, repositories, *, *, allow
        p, role:org-admin, accounts, *, *, allow
        p, role:org-admin, gpgkeys, *, *, allow
        g, {{ .Values.adminGroup }}, role:org-admin
  configs:
    secret:
      extra:
        oidc.plural.clientSecret: {{ .OIDC.ClientSecret }}
  dex:
    enabled: false
  {{ end }}
