data "http" "aws_load_balancer_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM permissions for the AWS Load Balancer Controller"
  policy      = data.http.aws_load_balancer_controller_iam_policy.response_body

  tags = {
    Project = "TechChallenge2"
  }
}