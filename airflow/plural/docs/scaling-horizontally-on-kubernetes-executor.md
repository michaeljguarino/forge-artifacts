## Scaling Horizontally on KubernetesExecutor

These are steps that we recommend to scale Airflow when using the `KubernetesExecutor`

___

### optimize the base airflow image

Remove unnecessary dependencies from your Docker images to speed up container deployments and reduce resource usage.

___

### set cpu and memory requirements for airflow tasks

To prevent resource contention amongst Airflow tasks and ensure smooth task execution, set appropriate resource request and limits to every single Airflow Task. On Plural, you can set a default pod size for your tasks like so:

```yaml
airflow:
  airflow:
    airflow:
      config:
      kubernetesPodTemplate:
        resources:
          limits:
            cpu: 1
            memory: 1Gi
          requests:
            cpu: 0.5
            memory: 512Mi
```

However, you can override the default settings for a task (if it needs more resources) in your Airflow code like so:

```python
import pendulum
import time

from airflow import DAG
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.example_dags.libs.helper import print_stuff
from kubernetes.client import models as k8s


k8s_exec_config_resource_requirements = {
    "pod_override": k8s.V1Pod(
        spec=k8s.V1PodSpec(
            containers=[
                k8s.V1Container(
                    name="base",
                    resources=k8s.V1ResourceRequirements(
                        requests={"cpu": 0.5, "memory": "1024Mi"},
                        limits={"cpu": 0.5, "memory": "1024Mi"}
                    )
                )
            ]
        )
    )
}

with DAG(
    dag_id="example_kubernetes_executor_pod_override_sources",
    schedule=None,
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    catchup=False
):
    BashOperator(
      task_id="bash_resource_requirements_override_example",
      bash_command="echo hi",
      executor_config=k8s_exec_config_resource_requirements
    )

    @task(executor_config=k8s_exec_config_resource_requirements)
    def resource_requirements_override_example():
        print_stuff()
        time.sleep(60)

    resource_requirements_override_example()
```
___

### setting [worker_pods_creation_batch_size](https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/configurations-ref.html#worker-pods-creation-batch-size)

This variable determines how many pods can be created per scheduler loop. The default is 1 in open source, but you'll want to increase this number for better performance, especially if you have concurrent tasks. The maximum value is determinded by the tolerance of your Kubernetes  cluster. On Plural, we recommend setting this to 16 as a starting point.

```yaml
airflow:
  airflow:
    airflow:
      config:
        AIRFLOW__KUBERNETES__WORKER_PODS_CREATION_BATCH_SIZE: 16
```
___

### running airflow tasks on custom node groups

There may be a desire to run your Airflow tasks on a specific node size for large workloads, or maybe even 
[spot instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) to achieve higher cost 
savings.

> Disclaimer: if you run your Airflow workloads on spot instances, it is highly recommended to [set retries](https://docs.astronomer.io/learn/rerunning-dags) 
> for your tasks as they may lose their underlying compute at any time

__Step 1: Create Custom Node Group__

In order to run your Airflow Tasks on custom configure nodes, you will need to first follow [these docs](https://docs.plural.sh/operations/cluster-configuration#modifying-node-types)
to create your desired nodes. For example, if you were on AWS and wanted to use spot instances you would add something 
like this to your `bootstrap/terraform/main.tf` file:

```yaml
multi_az_node_groups = {
  medium_burst_spot = {
      name = "medium-burst-spot"
      min_capacity = 3
      desired_capacity = 3
      instance_types = ["t3.xlarge", "t3a.xlarge"]
      capacity_type = "SPOT"
      k8s_labels = {
        "plural.sh/capacityType" = "SPOT"
        "plural.sh/performanceType" = "BURST"
        "plural.sh/scalingGroup" = "medium-burst-spot"
      }
      k8s_taints = [{
        key = "plural.sh/capacityType"
        value = "SPOT"
        effect = "NO_SCHEDULE"
      }]
    }
}
```

Then run `plural deploy --commit "add more spot nodes"` to update your cluster.

> ! If you get an error like `InvalidParameterException: Minimum capacity 3 can't be greater than desired size 0` you 
> may have to use your cloud CLI or console to enact the change manually and then try running again.


__Step 2: Update Airflow to Use Node Group__

After creating your custom node group, you can point configure Airflow to use it by adding the following to your 
`./airflow/helm/values.yaml` (this can also be done in the plural application console)

```yaml
airflow:
  airflow:
    airflow:
      config:
      kubernetesPodTemplate:
        nodeSelector:
          plural.sh/capacityType: SPOT
        tolerations:
        - effect: NoSchedule
          key: plural.sh/capacityType
          operator: Equal
          value: SPOT
```


### redeploy

From there, you should be able to run `plural build --only airflow && plural deploy --commit "optimize kubernetesexecutor"` to 
use the custom node group to execute your tasks.