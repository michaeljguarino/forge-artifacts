{{ $hydraHost := .Values.hostname }}
{{ $adminHost := .Values.adminHostname }}
{{ $hydraPassword := dedupe . "hydra.postgres.password" (randAlphaNum 20) }}
{{ $hydraDsn := default (printf "postgres://hydra:%s@plural-postgres-hydra:5432/hydra" $hydraPassword) .Values.postgresDsn }}

global:
  application:
    links:
    - description: hydra api
      url: {{ $hydraHost }}
    {{ if $adminHost }}
    - description: hydra admin api
      url: {{ $adminHost }}
    {{ end }}

postgres:
  password: {{ $hydraPassword }}
  dsn: {{ $hydraDsn }}

{{ $systemSecret := dig "hydra" "hydra" "hydra" "config" "secrets" "system" (list ) . }}

hydra:
  hydra:
    config:
      dsn: {{ $hydraDsn }}
      secrets:
      {{ if not $systemSecret }}
        system: [{{ (randAlphaNum 20 )}}]
      {{ else }}
        system: 
        {{ toYaml $systemSecret | nindent 8 }}
      {{ end }}
        cookie: {{ dedupe . "hydra.hydra.hydra.config.secrets.cookie" (randAlphaNum 20) }}
      urls:
        self:
          issuer: https://{{ $hydraHost }}/
        login: {{ .Values.loginUrl }}
        consent: {{ .Values.consentUrl }}
  ingress:
    public:
      hosts:
      - host: {{ $hydraHost }}
        paths: 
        - path: "/.*"
          pathType: ImplementationSpecific
      tls:
      - hosts:
        - {{ $hydraHost }}
        secretName: hydra-tls
    {{ if $adminHost }}
    admin:
      enabled: true
      hosts:
      - host: {{ $adminHost }}
        paths: 
        - path: "/.*"
          pathType: ImplementationSpecific
      tls:
      - hosts:
        - {{ $adminHost }}
        secretName: hydra-admin-tls
    {{ end }}