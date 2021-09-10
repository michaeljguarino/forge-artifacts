secret:
  rootPassword: {{ dedupe . "mysql-cluster.secret.rootPassword" (randAlphaNum 20) }}
