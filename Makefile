.PHONY: help

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: upload-bootstrap upload-plural upload-console upload-airflow upload-gitlab upload-sentry upload-grafana upload-postgres

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

upload-crossplane: # uploads crossplane artifacts
	plural apply -f crossplane/Pluralfile

import-operator:
	cp ../plural-operator/config/crd/bases/* bootstrap/plural/crds/bootstrap