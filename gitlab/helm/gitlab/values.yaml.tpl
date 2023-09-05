{{ $isGcp := or (eq .Provider "google") (eq .Provider "gcp") }}
global:
  application:
    links:
    - description: gitlab web ui
      url: gitlab.{{ .Network.Subdomain }}
    - description: gitlab docker registry
      url: registry.{{ .Network.Subdomain }}

  {{ if .Network }}
  hosts:
    domain: {{ .Network.Subdomain }}
  {{ end }}
  {{ if .SMTP }}
  email:
    display_name: GitLab
    from: {{ .SMTP.Sender }}
  smtp:
    enabled: true
    address: {{ .SMTP.Server }}
    authentication: 'plain'
    port: {{ .SMTP.Port }}
    user_name: {{ .SMTP.User }}
  {{ end }}
  registry:
    bucket: {{ .Values.registryBucket }}
  appConfig:
    {{ if .OIDC }}
    omniauth:
      enabled: true
      autoLinkUser: true
      allowSingleSignOn: true
      blockAutoCreatedUsers: false
      providers:
      - secret: plural-oidc-provider
        key: provider
    {{ end }}
    lfs:
      bucket: {{ .Values.lfsBucket }}
    artifacts:
      bucket: {{ .Values.artifactsBucket }}
    uploads:
      bucket: {{ .Values.uploadsBucket }}
    packages:
      bucket: {{ .Values.packagesBucket }}
    backups:
      bucket: {{ .Values.backupsBucket }}
      tmpBucket: {{ .Values.backupsTmpBucket }}
    object_store:
      enabled: true
      connection:
        secret: objectstore-connection
        key: connection
  serviceAccount:
    {{ if $isGcp }}
    create: false
    {{ end }}
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::{{ .Project }}:role/{{ .Cluster }}-gitlab"

{{ if $isGcp }}
serviceAccount:
  create: false
  name: gitlab-runner
{{ end }}

{{ if .OIDC }}
oidc:
  name: openid_connect
  label: Plural
  icon: https://plural-assets.s3.us-east-2.amazonaws.com/uploads/repos/3fbf2a2b-6416-4245-ad28-3c2fb74aac86/plural-logo.png?v=63791948408
  args:
    name: openid_connect
    issuer: {{ .OIDC.Configuration.Issuer }}
    scope: [openid]
    discovery: true
    client_options:
      identifier: {{ .OIDC.ClientId }}
      secret: {{ .OIDC.ClientSecret }}
      redirect_uri: https://gitlab.{{ .Network.Subdomain }}/users/auth/openid_connect/callback
{{ end }}

{{ if .SMTP }}
smtpPassword: {{ .SMTP.Password }}
{{ end }}
rootPassword: {{ dedupe . "gitlab.rootPassword" (randAlphaNum 20) }}

{{ $minio := .Configuration.minio.hostname | quote }}
gitlab:
  registry:
    storage:
      secret: registry-connection
      key: config
    runners:
      cache:
      {{ if eq .Provider "aws" }}
        cacheType: s3
        s3BucketName: {{ .Values.runnerCacheBucket }}
        s3BucketLocation: {{ .Region }}
      {{ end }}
      {{ if $isGcp }}
        cacheType: gcs
        gcsBucketName: {{ .Values.runnerCacheBucket }}
      {{ end }}
      {{ if eq .Provider "azure" }}
        cacheType: s3
        s3BucketName: {{ .Values.runnerCacheBucket }}
        s3ServerAddress: {{ $minio }}
        secretName: s3credentials
      {{ end }}

railsConnection:
{{ if $isGcp }}
  provider: Google
  google_project: {{ .Project }}
  google_application_default: true
{{ end }}
{{ if eq .Provider "aws" }}
  provider: AWS
  region: {{ .Region }}
  use_iam_profile: true
{{ end }}
{{ if eq .Provider "azure" }}
  provider: AWS
  endpoint: {{ $minio }}
  aws_access_key_id: {{ importValue "Terraform" "access_key_id" }}
  aws_secret_access_key: {{ importValue "Terraform" "secret_access_key" }}
  aws_signature_version: 4
{{ end }}

registryConnection:
{{ if eq .Provider "aws" }}
  s3:
    bucket: {{ .Values.registryBucket }}
    region: {{ .Region }}
    v4auth: true
{{ end }}
{{ if $isGcp }}
  gcs:
    bucket: {{ .Values.registryBucket }}
{{ end }}
{{ if eq .Provider "azure" }}
  s3:
    regionendpoint: {{ $minio }}
    bucket: {{ .Values.registryBucket }}
    accesskey: {{ importValue "Terraform" "access_key_id" }}
    secretkey: {{ importValue "Terraform" "secret_access_key" }}

s3secret:
  accesskey: {{ importValue "Terraform" "access_key_id" }}
  secretkey: {{ importValue "Terraform" "secret_access_key" }}
{{ end }}
