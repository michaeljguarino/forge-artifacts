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
          'objectstore' => array(
            'class' => '\\OC\\Files\\ObjectStore\\S3',
            'arguments' => array(
              'bucket'     => '{{ .Values.nextcloud_bucket }}',
              'autocreate' => true,
              'key'        => getenv('S3_KEY'),
              'secret'     => getenv('S3_SECRET'),
              'region'     => 'us-east-2',
              'use_ssl'    => true
            )
          )
        );
    {{ $redisNamespace := namespace "redis" }}
    extraEnv:
      - name: REDIS_HOST
        value: redis-master.{{ $redisNamespace }}
      - name: REDIS_HOST_PORT
        value: 6379
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
redisPassword: $creds

secret:
  username: admin
  password: {{ dedupe . "nextcloud.secret.password" (randAlphaNum 14) }}

postgresqlPassword: {{ dedupe . "nextcloud.postgresqlPassword" (randAlphaNum 20) }}
