data "aws_iam_policy_document" "api_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.nodes_role]
    }
  }
}

data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/convox/*"
    ]
  }
}

resource "aws_iam_role" "logs" {
  name               = "${var.name}-logs"
  assume_role_policy = data.aws_iam_policy_document.api_assume.json
  path               = "/convox/"
  tags               = local.tags
}

resource "aws_iam_role_policy" "logs" {
  name   = "logs"
  role   = aws_iam_role.logs.name
  policy = data.aws_iam_policy_document.logs.json
}