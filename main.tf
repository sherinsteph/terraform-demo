terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
# provider "aws" {
#   alias  = "change"
#   region = "us-west-2"
# }

provider "aws" {
  alias      = "uswest"
  access_key = ""
  secret_key = ""
  region     = "us-west-2"
}

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-southeast-1"
}


# Create a S3 Bucket
resource "aws_s3_bucket" "a" {
  provider = aws.uswest
  bucket   = "data-extractor-demo"
  acl      = "private"
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_public_access_block" "s3Public-bucketa" {
  provider                = aws.uswest
  bucket                  = "data-extractor-demo"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  depends_on = [
    aws_s3_bucket.a,
  ]
}

# # Upload an object
# resource "aws_s3_bucket_object" "object" {
#   bucket = "data-extractor-demo"
#   acl    = "private"
#   key    = "/"
#   source = "data/DataExtractor.zip"
#   etag   = filemd5("data/DataExtractor.zip")
# }



# Create a S3 Bucket
resource "aws_s3_bucket" "bucket2" {
  bucket = "file-uploader-saved-files-demo"
  acl    = "private"
  depends_on = [
    aws_s3_bucket.a,
  ]
}
resource "aws_s3_bucket" "bucket3" {
  bucket = "insecure-corp-demo"
  acl    = "public-read-write"
  depends_on = [
    aws_s3_bucket.a,
  ]
}


resource "aws_s3_bucket" "bucket4" {
  bucket = "developers-secret-bucket-demo"
  acl    = "private"
  depends_on = [
    aws_s3_bucket.a,
  ]
}


# resource "aws_s3_bucket" "example" {
#   bucket = "example"
# }

# resource "aws_s3_bucket_ownership_controls" "bucket4-policy" {
#   bucket = "developers-secret-bucket-demo"

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
#   depends_on = [
#     aws_s3_bucket.bucket4,
#   ]
# }

# resource "aws_s3_bucket_public_access_block" "s3Public-bucket4" {
#   bucket                  = "developers-secret-bucket-demo"
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
#   depends_on = [
#     aws_s3_bucket.bucket4,
#   ]
# }


resource "aws_s3_bucket_object" "object" {
  provider = aws.uswest
  bucket   = "data-extractor-demo"
  key      = "DataExtractor.zip"
  source   = "DataExtractor.zip"
  etag     = filemd5("DataExtractor.zip")
  depends_on = [
    aws_s3_bucket.a,
  ]
}
resource "aws_s3_bucket_object" "object1" {
  provider = aws.uswest
  bucket   = "data-extractor-demo"
  key      = "DataExtractor.zip"
  source   = "DataExtractor.zip"
  etag     = filemd5("DataExtractor.zip")
  depends_on = [
    aws_s3_bucket_object.object,
  ]
}
resource "aws_s3_bucket_object" "object2" {
  provider = aws.uswest
  bucket   = "data-extractor-demo"
  key      = "DataExtractor.zip"
  source   = "DataExtractor.zip"
  etag     = filemd5("DataExtractor.zip")
  depends_on = [
    aws_s3_bucket_object.object1,
  ]
}



resource "aws_s3_bucket_policy" "allow_access_from_another_account1" {
  bucket = "developers-secret-bucket-demo"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "UserSpecificConditions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::677510197187:user/sherin"         
            },
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutBucketWebsite"
            ],
            "Resource": [
                "arn:aws:s3:::developers-secret-bucket-demo",
                "arn:aws:s3:::developers-secret-bucket-demo/*"
            ]
        }
    ]
}
POLICY
  depends_on = [
    aws_s3_bucket.bucket4,
  ]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = "insecure-corp-demo"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::insecure-corp-demo",
                "arn:aws:s3:::insecure-corp-demo/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:Put*",
            "Resource": [
                "arn:aws:s3:::insecure-corp-demo",
                "arn:aws:s3:::insecure-corp-demo/*"
            ]
        }
    ]
}
POLICY
  depends_on = [
    aws_s3_bucket.bucket3,
  ]
}
