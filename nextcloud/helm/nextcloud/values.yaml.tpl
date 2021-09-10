{{ $hostname := default "example.com" .Values.hostname }}
nextcloud:
  ingress:
    tls:
      - secretName: nextcloud-tls
        hosts:
          - {{ $hostname }}
  nextcloud:
    host: {{ $hostname }}
    existingSecret:
      enabled: true
      secretName: nextcloud-creds
      usernameKey: nextcloud-username
      passwordKey: nextcloud-password
      smtpUsernameKey: smtp-username
      smtpPasswordKey: smtp-password
    configs:
      s3.config.php: |-
        <?php
        $CONFIG = array (
          'filelocking.enabled' => false,
          'objectstore' => array(
            'class' => '\\OC\\Files\\ObjectStore\\S3',
            'arguments' => array(
              'bucket'     => '{{ .Values.nextcloud_bucket }}',
              'autocreate' => false,
              'key'        => getenv('S3_KEY'),
              'secret'     => getenv('S3_SECRET'),
              {{- if eq .Provider "azure" }}
              'hostname'   => {{- .Configuration.minio.hostname | quote -}},
              'region'     => 'us-east-1',
              'use_path_style'=>true,
              {{- else }}
              'region'     => 'us-east-2',
              {{- end }}
              'use_ssl'    => true
            )
          )
        );
    {{ $redisNamespace := namespace "redis" }}
    extraEnv:
      - name: S3_KEY
        valueFrom:
          secretKeyRef:
            name: nextcloud-s3-secret
            key: username
      - name: S3_SECRET
        valueFrom:
          secretKeyRef:
            name: nextcloud-s3-secret
            key: password
      - name: REDIS_HOST
        value: redis-master.{{ $redisNamespace }}
      - name: REDIS_HOST_PORT
        value: "6379"
      - name: REDIS_HOST_PASSWORD
        valueFrom:
          secretKeyRef:
            name: redis-secret
            key: password
  externalDatabase:
    enabled: true
    type: postgresql
    host: plural-nextcloud
    existingSecret:
      enabled: true
      secretName: nextcloud.plural-nextcloud.credentials.postgresql.acid.zalan.do
      usernameKey: username
      passwordKey: password

{{ $creds := secret $redisNamespace "redis-password" }}
redisPassword: {{ $creds.password }}

secret:
  username: admin
  password: {{ dedupe . "nextcloud.secret.password" (randAlphaNum 14) }}

postgresqlPassword: {{ dedupe . "nextcloud.postgresqlPassword" (randAlphaNum 20) }}
