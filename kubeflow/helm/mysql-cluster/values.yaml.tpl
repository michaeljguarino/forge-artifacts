secrets:
  root: {{ dedupe . "mysql-cluster.secrets.root" (randAlphaNum 20) }}
  xtrabackup: {{ dedupe . "mysql-cluster.secrets.xtrabackup" (randAlphaNum 20) }}
  monitor: {{ dedupe . "mysql-cluster.secrets.monitor" (randAlphaNum 20) }}
  clustercheck: {{ dedupe . "mysql-cluster.secrets.clustercheck" (randAlphaNum 20) }}
  proxyadmin: {{ dedupe . "mysql-cluster.secrets.proxyadmin" (randAlphaNum 20) }}
  pmmserver: {{ dedupe . "mysql-cluster.secrets.pmmserver" (randAlphaNum 20) }}
  operator: {{ dedupe . "mysql-cluster.secrets.operator" (randAlphaNum 20) }}
  replication: {{ dedupe . "mysql-cluster.secrets.replication" (randAlphaNum 20) }}
  kubeflow_password: {{ dedupe . "mysql-cluster.secrets.kubeflow_password" (randAlphaNum 20) }}
