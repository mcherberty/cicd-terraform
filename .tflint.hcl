# Terraform TFLint Configuration
# Linting rules for code quality

plugin "terraform" {
  enabled = true
  version = "0.4.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

plugin "google" {
  enabled = true
  version = "0.24.1"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Google Cloud specific rules
rule "google_compute_instance_invalid_machine_type" {
  enabled = true
}

rule "google_compute_disk_invalid_image" {
  enabled = true
}
