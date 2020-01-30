aws cloudformation create-stack \
  --stack-name "capstone" \
  --template-body file://$PWD/infrastructure.yaml \
  --capabilities CAPABILITY_NAMED_IAM
