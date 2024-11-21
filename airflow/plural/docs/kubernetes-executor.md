## Configuring KubernetesExecutor

The [KubernetesExecutor](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/kubernetes.html) 
in Apache Airflow is a valuable choice for specific use cases and scenarios. It offers several advantages that make it a 
suitable execution engine for running your Airflow tasks.

### edit values.yaml

You'll then want to edit `airflow/helm/airflow/values.yaml` in your installation repo with something like:

```yaml
airflow:
  airflow:
    airflow:
      config:
        AIRFLOW__KUBERNETES__WORKER_PODS_CREATION_BATCH_SIZE: 5
      executor: KubernetesExecutor
      kubernetesPodTemplate:
        resources:
          limits:
            cpu: 1
            memory: 1Gi
          requests:
            cpu: 0.5
            memory: 512Mi
    flower:
      enabled: false
    redis:
      enabled: false
    workers:
      enabled: false
  secrets:
    createPluralRedisSecret: true
```

The resources that you configure in the `kubernetesPodTemplate` section will determine the amount of resources that will 
be available to your Airflow tasks, so if you get SIGTERM errors from your Airflow tasks, you may need to increase the 
default cpu/memory and limits accordingly.

Additionally, we recommend to increase the [worker_pods_creation_batch_size](https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/configurations-ref.html#worker-pods-creation-batch-size)
for your production workloads. This guide has it set to `5`, but you will need to experiment what works best for your 
Airflow workloads to decrease any scheduling latency.

Alternatively, you should be able to do this in the configuration section for airflow in your plural console as well.

### redeploy

From there, you should be able to run `plural build --only airflow && plural deploy --commit "use kubernetesexecutor"` 
to use the Airflow kubernetesexecutor.