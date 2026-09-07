set default-list := true

plan:
    tofu -chdir=../tofu/ plan

apply:
    tofu -chdir=../tofu/ apply

destroy:
    tofu -chdir=../tofu/ destroy
