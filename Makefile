.PHONY: all

DEFAULT_TARGET: all

TF_BIN ?= terraform
AWS_REGION ?= us-east-1

# AWS_SDK_LOAD_CONFIG: to be able to use shared credentials. Refer to:
# https://docs.aws.amazon.com/sdk-for-go/api/aws/session/
TF_VARS = cd environments/$(ENV) && AWS_SDK_LOAD_CONFIG=1

TF_ARGS = $(TARGET)

check-env:
  ifndef ENV
    $(error ENV is undefined. Use 'ENV=<env>' <env> is any directory under /environments)
  endif

all: init plan

get:
	rake get_modules[$(ENV)]
	$(TF_VARS) $(TF_BIN) get

plan:
	$(TF_VARS) $(TF_BIN) plan $(TF_ARGS)

apply:
	$(TF_VARS) $(TF_BIN) apply $(TF_ARGS)

refresh:
	$(TF_VARS) $(TF_BIN) refresh $(TF_ARGS)

destroy:
	$(TF_VARS) $(TF_BIN) destroy $(TF_ARGS)
	utils/aws_utils.sh undo_links $(ENV)

clean:
	rake remove_modules[$(ENV)]
	utils/aws_utils.sh undo_links $(ENV)

prereqs:
	test -d environments/$(ENV)
	aws --version
	rake --version
	$(TF_BIN) -version

init:
	utils/aws_utils.sh prepare_deploy_links $(ENV)
	$(TF_VARS) $(TF_BIN) get
	$(TF_VARS) $(TF_BIN) init

errored:
	$(TF_VARS) $(TF_BIN) state push errored.tfstate

show:
	$(TF_VARS) $(TF_BIN) show

output:
	$(TF_VARS) $(TF_BIN) output $(OUTPUT)

import:
	$(TF_VARS) $(TF_BIN) import $(RESOURCE_NAME) $(RESOURCE_ID)
