#!/bin/bash

IMAGE="gcr-haskell-example:latest"
GCLOUD_PROJECT=`gcloud config list --format="value(core.project)"`
echo uploading image to gcr.io/$GCLOUD_PROJECT/$IMAGE
docker push gcr.io/$GCLOUD_PROJECT/$IMAGE
echo running- gcloud beta run deploy --image gcr.io/$GCLOUD_PROJECT/$IMAGE --platform managed --region=us-central1 
gcloud beta run deploy --image gcr.io/$GCLOUD_PROJECT/$IMAGE --platform managed --region=us-central1
