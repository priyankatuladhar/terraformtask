locals {
  common_tags = {
    Name    = "Assessment Section 2 Priyanka"
    Creator = "priyankatuladhar@lftechnology.com"
    Project = "Post Internship Training"
    Task    = "Terraform"
  }
}

# to call these local's tags in resources: 
# tags = local.common_tags

