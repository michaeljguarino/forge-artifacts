{{ $hostname := .Values.hostname }}
{{ $redisNamespace := namespace "redis" }}
argo-cd:
  controller:
    extraArgs:
      - --redis=redis-master.{{ $redisNamespace }}:6379
      - --redisdb=2
    envFrom:
      - secretRef:
          name: redis-secret
  repoServer:
    extraArgs:
      - --redis=redis-master.{{ $redisNamespace }}:6379
      - --redisdb=4
    envFrom:
      - secretRef:
          name: redis-secret
  server:
    extraArgs:
      - --redis=redis-master.{{ $redisNamespace }}:6379
      - --redisdb=3
    envFrom:
      - secretRef:
          name: redis-secret
    certificate:
      domain: {{ $hostname }}
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
        kubernetes.io/ingress.class: nginx
        kubernetes.io/tls-acme: "true"
        nginx.ingress.kubernetes.io/ssl-passthrough: "true"
        nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
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
  dex:
    enabled: false
    metrics:
      enabled: false
      serviceMonitor:
        enabled: false
  {{ end }}
  configs:
    {{ if .OIDC }}
    secret:
      extra:
        oidc.plural.clientSecret: {{ .OIDC.ClientSecret }}
    {{ end }}
    {{ if .Values.credentialTemplateURL }}
    credentialTemplates:
      https-creds:
        url: {{ .Values.credentialTemplateURL }}
        username: {{ .Values.credentialUsername }}
        password: {{ .Values.credentialPassword }}
    {{ end }}
    {{ if .Values.privateRepoName }}
    repositories:
      {{ .Values.privateRepoName }}:
        url: {{ .Values.privateRepoURL }}
    {{ end }}

{{ $creds := secret $redisNamespace "redis-password" }}
redisPassword: {{ $creds.password }}

{{ if .Values.enableImageUpdater }}
argocd-image-updater:
  enabled: true
  config:
    argocd:
      serverAddress: {{ $hostname }}
{{ end }}
