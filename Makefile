
PROJECT_NAME := protoworkflow
MODULE_NAME := sentiment

IMAGE_NAME := $(PROJECT_NAME)_$(MODULE_NAME)_grpc

# Programs / Tools
GO := /usr/local/go/bin/go
PROTOC := /usr/local/bin/protoc
DOCKER := /usr/bin/docker
MAKE := /usr/bin/make

# Protocol Buffer Variables
GOOGLE_APIS := $(HOME)/Documents/googleapis
PROTO_SELF := v1

# Workaround for building go docker file
# TODO: check if workaround is still needed
GO_GENERATED := $(HOME)/go/src/github.com/HayoVanLoon/go-generated
OUT := $(GO_GENERATED)/$(MODULE_NAME)/v1

TEST_ROOT := test
MOCK_TARGET := $(TEST_ROOT)/$(MODULE_NAME)/v1/$(MODULE_NAME)_mock.go


.PHONY:

clean:
	rm -rf $(OUT)

protoc: clean
	mkdir -p "$(OUT)"
	$(PROTOC) --go_out="plugins=grpc:$(OUT)" \
		--descriptor_set_out=api_descriptor.pb \
		-I"$(GOOGLE_APIS)" \
		-I"$(PROTO_SELF)" \
		v1/$(MODULE_NAME).proto

build: protoc
	$(DOCKER) build -t $(IMAGE_NAME) .

docker-run:
	$(DOCKER) run -p 8080:8080 $(IMAGE_NAME)


push-gcr:
	docker tag $(IMAGE_NAME) gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):latest
	docker push gcr.io/$(PROJECT_ID)/$(IMAGE_NAME)

#
#mocks:
#	mkdir -p "$(TEST_ROOT)/$(ENVY_OUT)"
#	rm "$(MOCK_TARGET)"
#	mockgen -source envy/v1/envy.pb.go >> "$(MOCK_TARGET)"
#
#build:
#	$(go) build -i -o /dist/Envy_Server github.com/HayoVanLoon/envy/envy_server
#
#test-client: protoc
#	$(GO) build -i -o /tmp/___Envy_Client github.com/HayoVanLoon/envy/envy_client #gosetup
#	/tmp/___Envy_Client #gosetup
