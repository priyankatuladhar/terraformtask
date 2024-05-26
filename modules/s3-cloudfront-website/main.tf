locals {
  s3_bucket_name = var.bucket_name
  s3_origin_id   = "myS3Origin"
  common_tags = {
    Name    = "Assessment Section 2 Priyanka"
    Creator = "priyankatuladhar@lftechnology.com"
    Project = "Post Internship Training"
    Task    = "Terraform"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.s3_bucket_name
  tags   = local.common_tags
}

resource "aws_cloudfront_distribution" "distribution" {
  depends_on = [
    aws_s3_bucket.bucket,
    aws_cloudfront_origin_access_control.oac
    ]
  enabled             = true
  default_root_object = "index.html"

  origin {
  domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
  origin_id                = local.s3_origin_id
  origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
  allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  cached_methods         = ["GET", "HEAD", "OPTIONS"]
  cache_policy_id        = "2e54312d-136d-493c-8eb9-b001f22f67d2"
  target_origin_id       = local.s3_origin_id
  viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = local.common_tags

}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-cloudfront-oac-test-new"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

data "aws_iam_policy_document" "cloudfront_oac_access" {
  depends_on = [ 
    aws_cloudfront_distribution.distribution,
    aws_s3_bucket.bucket
   ]
  statement {
    sid = "3"
    effect = "Allow"
    actions   = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.Site_Origin.bucket}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [
        aws_cloudfront_distribution.distribution.arn
      ]
    }
  }

}

resource "aws_s3_bucket_policy" "policy" {

  depends_on = [ 
    aws_cloudfront_distribution.distribution
   ]
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.cloudfront_oac_access.json

}

resource "aws_s3_object" "content" {
  depends_on = [ 
    aws_s3_bucket.bucket
   ]
  bucket                 = aws_s3_bucket.bucket.bucket
  key                    = "index.html"
  source                 = "./index.html"
  # server_side_encryption = "AES256"

  content_type = "text/html"
}