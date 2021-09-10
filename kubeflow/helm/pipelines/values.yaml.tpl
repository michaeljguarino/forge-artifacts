config:
  databases:
    connection:
      password: {{ dedupe . "pipelines.config.databases.connection.password" (randAlphaNum 20) }}
