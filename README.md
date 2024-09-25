# Portfolio Static Website Hosting using Terraform and AWS.

## Description
I used terraform as infrastructure as code(IaC) to create a porfolio static website that is hosted and distributed using Cloudfront with an S3 bucket as its origin. I manually created the certificate via AWS Certificate Manager(ACM) and created the domain using Route53.


## Requirements: 

* AWS account
* AWS CLI
* Terraform

## Terraform commands to create AWS resources:

1. terraform init
2. terraform plan
3. terraform apply

### Once the resources have been created using the terraform commands. The rest of the AWS infrastructure can be set up manually. 


## Resources:
* aws_s3_bucket
* aws_s3_bucket_website_configuration
* aws_s3_bucket_versioning
* aws_s3_bucket_public_access_block
* aws_s3_bucket_policy
* aws_cloudfront_distribution
* aws_cloudfront_origin_access_control

   

