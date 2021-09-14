{{- if .OIDC }}
oidcSecret:
  clientID: {{ .OIDC.ClientId }}
  clientSecret: {{ .OIDC.ClientSecret }}
{{- end }}
argo-workflows:
  server:
    ingress:
      enabled: true
      annotations:
        kubernetes.io/tls-acme: "true"
        kubernetes.io/ingress.class: "nginx"
        cert-manager.io/cluster-issuer: letsencrypt-prod
        nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
        nginx.ingress.kubernetes.io/use-regex: "true"
      hosts:
        - {{ .Values.hostname }}
      paths:
        - /
      pathType: Prefix
      tls:
        - secretName: argoworkflows-tls
          hosts:
            - {{ .Values.hostname }}
      https: true
  {{- if .OIDC }}
    securityContext:
      fsGroup: 65534
    sso:
      issuer: {{ .OIDC.Configuration.Issuer }}
      clientId:
        name: oidc-secret
        key: clientID
      clientSecret:
        name: oidc-secret
        key: clientSecret
      redirectUrl: https://{{ .Values.hostname }}/oauth2/callback
      rbac:
        enabled: true
      scopes:
      - openid
      - profile
  {{- end }}
  {{- if eq .Provider "aws" }}
  useStaticCredentials: false
artifactRepository:
  archiveLogs: true
  s3:
    insecure: false
    bucket: {{ .Values.workflowBucket | quote }}
    endpoint: s3.amazonaws.com
    useSDKCreds: true
    roleARN: "arn:aws:iam::{{ .Project }}:role/{{ .Cluster }}-argo-workflows"
    keyFormat: {{ printf "\"{{workflow.namespace}}/{{workflow.name}}/{{pod.name}}\"" }}
serviceAccount:
  create: true
  annotations:
    workflows.argoproj.io/rbac-rule: "'david@plural.sh' in sub"
    workflows.argoproj.io/rbac-rule-precedence: "1"
    eks.amazonaws.com/role-arn: "arn:aws:iam::{{ .Project }}:role/{{ .Cluster }}-argo-workflows"
  {{- end }}
