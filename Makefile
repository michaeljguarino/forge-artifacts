.PHONY: help

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: upload-bootstrap upload-plural upload-console upload-airflow upload-gitlab upload-sentry upload-grafana upload-postgres

import-operator:
	cp ../plural-operator/config/crd/bases/* bootstrap/plural/crds/bootstrap

create-template:
	@read -p "Enter Application Name:" application; \
	mkdir -p ./$$application/helm; \
	helm create ./$$application/helm/$$application; \
	echo "apiVersion: plural.sh/v1alpha1\nkind: Dependencies\nmetadata:\n  application: true\n  description: Deploys $$application crafted for the target cloud\nspec:\n  dependencies:\n  - type: helm\n    name: bootstrap\n    repo: bootstrap\n    version: '>= 0.5.1'\n  - type: terraform\n    name: aws\n    repo: $$application\n    version: '>= 0.1.0'\n    optional: true\n  - type: terraform\n    name: azure\n    repo: $$application\n    version: '>= 0.1.0'\n    optional: true\n  - type: terraform\n    name: gcp\n    repo: $$application\n    version: '>= 0.1.0'\n    optional: true" > ./$$application/helm/$$application/deps.yaml; \
	echo "# $$application\n\nInstalls $$application using Plural." > ./$$application/helm/$$application/README.md; \
	echo "{}" > ./$$application/helm/$$application/values.yaml.tpl; \
	mkdir -p ./$$application/plural/icons; \
	mkdir -p ./$$application/plural/crds; \
	mkdir -p ./$$application/plural/recipes; \
	mkdir -p ./$$application/plural/tags/helm; \
	mkdir -p ./$$application/plural/tags/terraform; \
	echo "{}" > ./$$application/plural/notes.tpl; \
	echo "name: $$application-aws\ndescription: Installs $$application on an aws eks cluster\nprovider: AWS\ndependencies:\n- repo: bootstrap\n  name: aws-k8s\nsections:\n- name: $$application\n  items:\n  - type: TERRAFORM\n    name: aws\n    configuration: []\n  - type: HELM\n    name: $$application\n    configuration: []" > ./$$application/plural/recipes/$$application-aws.yaml; \
	echo "name: $$application-azure\ndescription: Installs $$application on an azure aks cluster\nprovider: AZURE\ndependencies:\n- repo: bootstrap\n  name: azure-k8s\nsections:\n- name: $$application\n  items:\n  - type: TERRAFORM\n    name: azure\n    configuration: []\n  - type: HELM\n    name: $$application\n    configuration: []" > ./$$application/plural/recipes/$$application-azure.yaml; \
	echo "name: $$application-gcp\ndescription: Installs $$application on a gcp gke cluster\nprovider: GCP\ndependencies:\n- repo: bootstrap\n  name: gcp-kubernetes\nsections:\n- name: $$application\n  items:\n  - type: TERRAFORM\n    name: gcp\n    configuration: []\n  - type: HELM\n    name: $$application\n    configuration: []" > ./$$application/plural/recipes/$$application-gcp.yaml; \
	echo "spec:\n  chart: $$application\n  version: 0.1.0\ntags:\n- stable\n- warm" > ./$$application/plural/tags/helm/$$application.yaml; \
	echo "spec:\n  terraform: aws\n  version: 0.1.0\ntags:\n- stable\n- warm" > ./$$application/plural/tags/terraform/aws.yaml; \
	echo "spec:\n  terraform: azure\n  version: 0.1.0\ntags:\n- stable\n- warm" > ./$$application/plural/tags/terraform/azure.yaml; \
	echo "spec:\n  terraform: gcp\n  version: 0.1.0\ntags:\n- stable\n- warm" > ./$$application/plural/tags/terraform/gcp.yaml; \
	mkdir -p ./$$application/terraform/aws; \
	mkdir -p ./$$application/terraform/azure; \
	mkdir -p ./$$application/terraform/gcp; \
	echo "apiVersion: plural.sh/v1alpha1\nkind: Dependencies\nmetadata:\n  description: $$application aws setup\n  version: 0.1.0\nspec:\n  dependencies:\n  - name: aws-bootstrap\n    repo: bootstrap\n    type: terraform\n    version: '>= 0.1.1'\n  providers:\n  - aws" > ./$$application/terraform/aws/deps.yaml; \
	echo "apiVersion: plural.sh/v1alpha1\nkind: Dependencies\nmetadata:\n  description: $$application azure setup\n  version: 0.1.0\nspec:\n  dependencies:\n  - name: azure-bootstrap\n    repo: bootstrap\n    type: terraform\n    version: '>= 0.1.1'\n  providers:\n  - azure" > ./$$application/terraform/azure/deps.yaml; \
	echo "apiVersion: plural.sh/v1alpha1\nkind: Dependencies\nmetadata:\n  description: $$application gcp setup\n  version: 0.1.0\nspec:\n  dependencies:\n  - name: gcp-bootstrap\n    repo: bootstrap\n    type: terraform\n    version: '>= 0.1.1'\n  providers:\n  - gcp" > ./$$application/terraform/gcp/deps.yaml; \
	echo "resource \"kubernetes_namespace\" \"$$application\" {\n  metadata {\n    name = var.namespace\n    labels = {\n      \"app.kubernetes.io/managed-by\" = \"plural\"\n      \"app.plural.sh/name\" = \"$$application\"\n    }\n  }\n}" > ./$$application/terraform/aws/main.tf; \
	echo "resource \"kubernetes_namespace\" \"$$application\" {\n  metadata {\n    name = var.namespace\n    labels = {\n      \"app.kubernetes.io/managed-by\" = \"plural\"\n      \"app.plural.sh/name\" = \"$$application\"\n    }\n  }\n}" > ./$$application/terraform/azure/main.tf; \
	echo "resource \"kubernetes_namespace\" \"$$application\" {\n  metadata {\n    name = var.namespace\n    labels = {\n      \"app.kubernetes.io/managed-by\" = \"plural\"\n      \"app.plural.sh/name\" = \"$$application\"\n    }\n  }\n}" > ./$$application/terraform/gcp/main.tf; \
	echo "namespace = {{ .Namespace | quote }}" > ./$$application/terraform/aws/terraform.tfvars; \
	echo "namespace = {{ .Namespace | quote }}" > ./$$application/terraform/azure/terraform.tfvars; \
	echo "namespace = {{ .Namespace | quote }}" > ./$$application/terraform/gcp/terraform.tfvars; \
	echo "variable \"namespace\" {\n  type = string\n  default = \"$$application\"\n}" > ./$$application/terraform/aws/variables.tf; \
	echo "variable \"namespace\" {\n  type = string\n  default = \"$$application\"\n}" > ./$$application/terraform/azure/variables.tf; \
	echo "variable \"namespace\" {\n  type = string\n  default = \"$$application\"\n}" > ./$$application/terraform/gcp/variables.tf; \
	echo "name: $$application\ndescription: PLACEHOLDER\ncategory: PLACEHOLDER\nicon: plural/icons/PLACEHOLDER\ndarkIcon: plural/icons/PLACEHOLDER\nnotes: plural/notes.tpl\noauthSettings:\n  uriFormat: PLACEHOLDER\n  authMethod: PLACEHOLDER\ntags:\n- tag: PLACEHOLDER" > ./$$application/repository.yaml; \
	echo "REPO $$application\nATTRIBUTES Plural repository.yaml\n\nTF terraform/*\nHELM helm/*\nRECIPE plural/recipes/*\nTAG plural/tags/**/*" > ./$$application/Pluralfile; \
	echo "\nupload-$$application: # uploads $$application artifacts\n	plural apply -f $$application/Pluralfile" >> ./Makefile

upload-airflow: # uploads airflow artifacts 
	plural apply -f airflow/Pluralfile

upload-bootstrap: # uploads k8s bootstrapping artifacts
	plural apply -f bootstrap/Pluralfile

upload-plural: # uploads plural platform artifacts
	plural apply -f plural/Pluralfile

upload-console: # uploads console artifacts
	plural apply -f console/Pluralfile

upload-gitlab: # uploads gitlab artifacts
	plural apply -f gitlab/Pluralfile

upload-sentry: # uploads sentry artifacts
	plural apply -f sentry/Pluralfile

upload-grafana: # uploads grafana artifacts
	plural apply -f grafana/Pluralfile

upload-postgres: # uploads postgres artifacts
	plural apply -f postgres/Pluralfile

upload-istio: # uploads istio artifacts
	plural apply -f istio/Pluralfile

upload-knative: # uploads knative artifacts
	plural apply -f knative/Pluralfile

upload-dex: # uploads dex artifacts
	plural apply -f dex/Pluralfile

upload-redis: # uploads redis artifacts
	plural apply -f redis/Pluralfile

upload-mysql: # uploads mysql artifacts
	plural apply -f mysql/Pluralfile

upload-kafka: # uploads kafka artifacts
	plural apply -f kafka/Pluralfile

upload-oauth2-proxy: # uploads oauth2-proxy artifacts
	plural apply -f oauth2-proxy/Pluralfile

upload-monitoring: # uploads monitoring artifacts
	plural apply -f monitoring/Pluralfile

upload-ghost: # uploads ghost artifacts
	plural apply -f ghost/Pluralfile

upload-rabbitmq: # uploads rabbitmq artifacts
	plural apply -f rabbitmq/Pluralfile

upload-nvidia-operator: # uploads nvidia-operator artifacts
	plural apply -f nvidia-operator/Pluralfile

upload-argo-cd: # uploads argo-cd artifacts
	plural apply -f argo-cd/Pluralfile

upload-kubecost: # uploads kubecost artifacts
	plural apply -f kubecost/Pluralfile

upload-etcd: # uploads etcd artifacts
	plural apply -f etcd/Pluralfile

upload-influx: # uploads influx artifacts
	plural apply -f influx/Pluralfile

upload-minio: # uploads minio artifacts
	plural apply -f minio/Pluralfile

upload-kubeflow: # uploads kubeflow artifacts
	plural apply -f kubeflow/Pluralfile

upload-goldilocks: # uploads goldilocks artifacts
	plural apply -f goldilocks/Pluralfile
