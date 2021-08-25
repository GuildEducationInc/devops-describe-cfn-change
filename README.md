# Github Action - Describe Cloudformation Changeset

An action to describe the CloudFormation change in the Pull Request.

The DevOps team uses this extensively in the [bootstrapper](https://github.com/GuildEducationInc/bootstrapper) and [devops-eks-cluster](https://github.com/GuildEducationInc/devops-eks-cluster) repos.

## Usage

```yaml
- uses: actions/checkout@v2
- uses: FranzDiebold/github-env-vars-action@v1.2.1

- name: Configure dev AWS credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{ secrets.DEVOPS_DEV_AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.DEVOPS_DEV_AWS_SECRET_ACCESS_KEY }}
    aws-region: us-west-2

- name: Create bootstrapper-kms-keys changeset
  id: bootstrapper-kms-keys
  uses: GuildEducationInc/devops-describe-cfn-changeset@main
  with:
    stack_name: bootstrapper-kms-keys
    template_body: shared/kms-keys.yaml
    parameters: >-
      ParameterKey=Environment,UsePreviousValue=true

- name: Post changeset to PR as a comment
  uses: thollander/actions-comment-pull-request@master
  with:
    message: ${{ steps.bootstrapper-kms-keys.outputs.result }}
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Env Vars
* `stack_name`: Cloudformation stack name to apply change (**required**)
* `template_body`: CloudFormation template file path (**required**)
