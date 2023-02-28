#Defaults
include .env
export #exports the .env variables

IMAGE ?= tulibraries/tul-hyku
VERSION ?= $(DOCKER_IMAGE_VERSION)
HARBOR ?= harbor.k8s.temple.edu
HYKU ?= ghcr.io/samvera/hyku

build:
	docker-compose build web --no-cache
	docker-compose build worker
	@docker tag $(HYKU)  $(HARBOR)/$(IMAGE)/web:$(VERSION)
	@docker tag $(HYKU)/worker $(HARBOR)/$(IMAGE)/worker:$(VERSION)
	@docker tag $(HYKU)  $(HARBOR)/$(IMAGE)/web:latest
	@docker tag $(HYKU)/worker $(HARBOR)/$(IMAGE)/worker:latest

scan:
	trivy image "$(HARBOR)/$(IMAGE)/web:$(VERSION)" --scanners vuln;

deploy:
	@docker push $(HARBOR)/$(IMAGE)/web:$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE)/web:latest; \
		fi
	@docker push $(HARBOR)/$(IMAGE)/worker:$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE)/worker:latest; \
		fi