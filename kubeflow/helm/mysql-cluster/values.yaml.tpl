secrets:
  rootPassword: {{ dedupe . "mysql-cluster.secrets.rootPassword" (randAlphaNum 20) }}
