{{ $jwtKey := dedupe . "hasura.hasura.jwt.key" (randAlphaNum 40) }}
{{ $prevDBName := dedupe . "hasura.hasura.pgClient.external.database" "hasura" }}
{{ $prevDBUsername := dedupe . "hasura.hasura.pgClient.external.username" "hasura" }}
{{ $prevDBHost := dedupe . "hasura.hasura.pgClient.external.host" "plural-hasura" }}
{{ $prevDBPort := dedupe . "hasura.hasura.pgClient.external.port | quote" "5432" }}
{{ $prevPostgresPwd := dedupe . "hasura.hasura.pgClient.external.password" (randAlphaNum 40) }}

global:
  application:
    links:
    - url: {{ .Values.hostname }}
      description: hasura dns name

ingress:
  host: {{ .Values.hostname }}

postgres:
  enabled: true

hasura:
  adminSecret: {{ dedupe . "hasura.hasura.adminSecret" (randAlphaNum 40) }}
  jwtSecret:
    key: {{ $jwtKey }}
    type: "HS256"
  jwt:
    key: {{ $jwtKey }}
{{ if .Values.postgresqlDisabled }}
  database:
    name: {{ dedupe . "hasura.hasura.database.name" $prevDBName }}
    username: {{ dedupe . "hasura.hasura.database.username" $prevDBUsername }}
    hostname: {{ dedupe . "hasura.hasura.database.hostname" $prevDBHost }}
    port: {{ dedupe . "hasura.hasura.database.port" $prevDBPort }}
    password: {{ dedupe . "hasura.hasura.database.password" $prevPostgresPwd }}
postgres:
  enabled: false
{{ end }}
