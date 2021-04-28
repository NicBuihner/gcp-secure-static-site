project = secure-static-site
service = cloud-storage-proxy
region = us-central1

deploy: push
	gcloud run deploy $(service) \
		--image gcr.io/$(project)/$(service) \
		--set-env=BUCKET_NAME="" \
		--project $(project) --region $(region)

.PHONY: build
push: build
	docker push gcr.io/$(project)/$(service)

build:
	docker build -t gcr.io/$(project)/$(service) .
