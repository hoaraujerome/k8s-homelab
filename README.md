# k8s-homelab

## Developer Setup

### Requirements

- TODO: devbox

### Steps

1. Clone this repo and cd
2. Install `pre-commit` hooks:

   ```sh
   pre-commit install
   ```

3. (Optional) Run pre-commit on all files:

   ```sh
   pre-commit run --all-files
   ```

## Usage

* SSH to the EC2 instance

   ```sh
   AWS_PROFILE="k8s_homelab" aws ec2-instance-connect ssh --instance-id i-07eb24daa48842f91 --os-user ubuntu --connection-type eice

   export AWS_PROFILE="k8s_homelab"
   ssh -i ~/.ssh/id_rsa_k8s_homelab ubuntu@i-07eb24daa48842f91 -o ProxyCommand='aws ec2-instance-connect open-tunnel --instance-id i-07eb24daa48842f91'
   ```
