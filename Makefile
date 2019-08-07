GCLOUD_PROJECT  :=$(shell gcloud config list --format="value(core.project)")
GCLOUD_REGION   :=$(shell gcloud config list --format="value(compute.region)")
GCLOUD_ZONE     :=$(shell gcloud config list --format="value(compute.zone)")
CLUSTER_NAME    :=$(shell gcloud config list --format="value(container.cluster)")

# path to executable depending on whether we use docker to build or build locally. Docker is consistent across developer machines
BINARY_PATH_LOCAL =".stack-work/docker/_home/.local/bin/app-exe"

all: build

## Build binary and docker images
build:
	@stack build --test --copy-bins
	@docker build . -t gcr.io/${GCLOUD_PROJECT}/gcr-haskell-example --build-arg BINARY_PATH=${BINARY_PATH_LOCAL}
	