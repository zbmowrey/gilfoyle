# gilfoyle
A Slack Bot which responds to Slash Commands with one of many possible insults. 

## Setup

### Backend

Rename .github/workflows/terraform/backend.tf.example (drop .example from the name). 

Then configure the backend in that file to your liking. 

### Workspace(s)

The full production workflow of this app makes use of **main**, **develop**,
and **staging** branches. Most developers will not need to use all 3 of these.
I recommend that you start with just *develop* for now. 

My convention has been to use **workspace names** that identically match the
**branch name** and my **AWS profile names**. This allows me to switch workspaces and
automatically point to the correct AWS account, and to tag/name resources with
the appropriate environment name. 

After running terraform init, go into Terraform Cloud and **update the settings
on your workspace**. You want to run deployments LOCALLY rather than remote. We
do this because TF Cloud isn't aware of the workspace name. 

### AWS Creds

Add the following to your ~/.aws/credentials file:

    [develop]
    aws_access_key_id=
    aws_secret_access_key=

Be sure to populate the expected values for each. Note that you can certainly
create a new profile name, new branch, and new workspace to match, and the
code will happily deploy when you manually use the terraform commands... but 
the Github action won't, because it's tied to the specific branches in question. 

### Github Secrets

Create this secret and populate it with your tf cloud token:

    TERRAFORM_CLOUD_TOKEN

If you intend to use a "main" workspace & branch: 

    AWS_KEY_MAIN
    AWS_SECRET_MAIN

If you intend to use a "develop" workspace & branch:

    AWS_KEY_DEVELOP
    AWS_SECRET_DEVELOP

If you intend to use a "staging" workspace & branch:

    AWS_KEY_STAGING
    AWS_SECRET_STAGING

Populating these values will allow Github to automatically deploy to your AWS account(s)
whenever code is merged/pushed to develop, staging, or main branches. You can watch
the deployment process in the Actions tab of your repository. 
