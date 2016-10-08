default: build

build:
	docker build -t prisms-image-builder .

sd-image: build
	docker run --rm --privileged prisms-image-builder
