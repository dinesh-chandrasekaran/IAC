terraform {
  backend "s3" {
    bucket         = "DynamoService-s3"
    key            = "default/terraform.tfstate" # path & file which will hold the state #
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock-dynamo" # dynamoDB to store state lock #
    encrypt        = "true"
  }
}

