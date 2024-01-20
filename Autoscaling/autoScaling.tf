# ----------------------------
# CONFIGURE AWS CONNECTION
# ----------------------------

provider "aws" {
  region = "ap-southeast-2"
}

module "ec2" {
  source = "./modules/ec2"
  ami_id       = "ami-0ac438f9a63fdd525"
  instance_type = "t2.micro"
  key_name      = "terraform-aws"
}

module "autoScaling" {
  source = "./modules/autoScaling"
  ami_id       = "ami-0ac438f9a63fdd525"
  instance_type = "t2.micro"
  key_name      = "terraform-aws"
}

module "sns" {
  source = "./modules/sns"
  autoscaling_group_name = module.autoScaling.autoscaling_group_name
}

module "loadAverageScale" {
  source = "./modules/loadAverage"
  auto_scaling_group_name = module.autoScaling.autoscaling_group_name
  sns_topic_arn = module.sns.sns_topic_arn
  region = "ap-southeast-2"

}
