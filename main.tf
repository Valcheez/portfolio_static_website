### Region

provider "aws" {
  region = var.aws_region 
}

### S3 Bucket

resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name
}

### S3 Website Config

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = var.bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

### S3 block public access

resource "aws_s3_bucket_public_access_block" "static_website_block" {
  bucket = var.bucket_name
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


### Bucket versioning

resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = var.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

### S3 Bucket Policy

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = var.bucket_name

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*", 
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.website_distribution.id}"
          }
        }
      }
    ]
  })
}

locals {
  s3_origin_id = "S3Origin"
}

### Cloudfront Distribution

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

### CloudFront distribution with OAC 

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "s3-cloudfront-oac"
  description                       = "Grants cloudfront access to s3 bucket ${aws_s3_bucket.static_website.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  
}