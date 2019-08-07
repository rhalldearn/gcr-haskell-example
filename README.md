# Haskell Serverless on GCR

## What does this example do exactly?

It builds this haskell project with stack using an FP Complete docker instance to build (consistent builds)
It takes the build output and creates a docker image from it based on ubuntu 18.04 base image
It deploys the instance to GCR (google cloud run)

## But what does it actually do?

The code just runs the servant Javascript.lhs example on GCR. See references below.

TODO: Find out how much it typically costs to run GCR and append here.

## References

https://github.com/knative/docs/tree/175313457f94baa036b400f12d162157edef70a7/community/samples/serving/helloworld-haskell
https://haskell-servant.readthedocs.io/en/stable/tutorial/Javascript.html
https://github.com/haskell-servant/servant/blob/master/doc/tutorial/Javascript.lhs
https://cloud.google.com/run/docs/quickstarts/build-and-deploy?hl=fi


