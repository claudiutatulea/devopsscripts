# Terraform native tests (terraform test command, requires Terraform >= 1.6)

variables {
  image_tag   = "test-sha"
  app_name    = "app"
  environment = "test"
}

run "validate_variables" {
  command = plan

  assert {
    condition     = var.image_tag == "test-sha"
    error_message = "image_tag variable must be passed through correctly"
  }
}
