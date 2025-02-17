locals {
  enabled   = module.this.enabled
  use_group = local.enabled && var.attach_permissions_to_group
}

resource "aws_iam_user" "default" {
  count = local.enabled ? 1 : 0

  name          = module.this.id
  tags          = module.this.tags
  force_destroy = true
}

resource "aws_iam_group" "default" {
  count = local.use_group ? 1 : 0

  name = module.this.id
}

# https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-Amazon-Web-Service.html
data "aws_iam_policy_document" "default" {
  statement {
    sid = "AllowOktaUserToListIamRoles"
    actions = [
      "iam:ListRoles",
      "iam:ListAccountAliases"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "default" {
  name        = module.this.id
  description = "Policy for Okta user"
  policy      = data.aws_iam_policy_document.default.json
  tags        = module.this.tags
}

resource "aws_iam_user_policy_attachment" "default" {
  count      = local.use_group ? 0 : 1
  user       = one(aws_iam_user.default[*].name)
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_group_policy_attachment" "default" {
  count      = local.use_group ? 1 : 0
  group      = one(aws_iam_group.default[*].name)
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_group_membership" "default" {
  count = local.use_group ? 1 : 0

  name = one(aws_iam_group.default[*].name)
  users = [
    one(aws_iam_user.default[*].name)
  ]
  group = one(aws_iam_group.default[*].name)
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = one(aws_iam_user.default[*].name)
}

resource "aws_ssm_parameter" "okta_user_access_key_id" {
  name        = "/sso/${module.this.id}/access_key_id"
  value       = aws_iam_access_key.default.id
  description = "Access Key ID for Okta user"
  type        = "SecureString"
  key_id      = var.kms_alias_name
  tags        = module.this.tags
}

resource "aws_ssm_parameter" "okta_user_secret_access_key" {
  name        = "/sso/${module.this.id}/secret_access_key"
  value       = aws_iam_access_key.default.secret
  description = "Secret Access Key for Okta user"
  type        = "SecureString"
  key_id      = var.kms_alias_name
  tags        = module.this.tags
}
