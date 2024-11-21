{{ $password := default "" .Values.password }}
{{ $tvEnabled := "false" }}

{{ if eq .Values.tvEnabled "y" }}
{{ $tvEnabled := "true" }}
{{ end }}

provider: {{ .Provider }}
hostname: {{ .Values.hostname }}

service:
  port: {{ .Values.port }}

tv:
  enabled: {{ $tvEnabled }}
  port: {{ .Values.tvPort }}

config:
  settings:
    token: {{ .Values.token }}
    {{ if $password }}
    password: {{ .Values.password }}
    {{ end }}
    rconPassword: {{ dedupe . "csgo.config.settings.rconPassword" (randAlphaNum 12) }}
    tickrate: {{ .Values.tickrate }}
    maxPlayers: {{ .Values.maxPlayers }}
