helm-pkg:
	@helm package flux-vela-extensions
.PHONY: helm-pkg

helm-push:
	@helm push flux-vela-extensions-0.1.0.tgz oci://docker.io/sujaykumarsuman
.PHONY: helm-push

helm: helm-pkg helm-push
	@echo "pushed chart to repo"

