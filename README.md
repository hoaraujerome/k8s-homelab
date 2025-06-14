# Cloud Homelab: Kubernetes Cluster (with kubeadm) on AWS 

## Description

This project sets up a Kubernetes cluster on AWS using `kubeadm`, as part of my hands-on journey to deepen my cloud-native and DevOps skills. After completing [Kubernetes the Hard Way](https://github.com/hoaraujerome/kubernetes-the-hard-way-on-aws) to understand the internals, I built this homelab environment to prepare for the Certified Kubernetes Administrator (CKA) exam and eventually host real-world workloads.

The infrastructure is provisioned using `Terraform`, and custom AMI for the control plane and worker nodes are built with `Packer` and `Ansible`. Nodes are deployed in private subnet, and I use `EC2 Instance Connect` for secure SSH access. For container networking, I chose `Cilium` as the CNI plugin to explore modern, eBPF-powered Kubernetes networking.

While my current job operates 100% in **Azure**, I deliberately chose **AWS** for this project to strengthen my **multi-cloud proficiency** and broaden my cloud engineering expertise.

I believe the best way to learn is to **get your hands dirty** — and this repo is a reflection of that mindset: learning by building, breaking, and improving.

To streamline development and ensure consistent tooling across environments, I use Devbox to manage the developer setup.

## Badges

![Status](https://img.shields.io/badge/status-Phase%201%20complete-blueviolet)
[![Powered by LazyVim](https://img.shields.io/badge/Powered_by-LazyVim-%2307a6c3?style=flat&logo=vim&logoColor=white)](https://lazyvim.org/)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

## Visuals

### Infrastructure

![K8S_Infra_Deployment_Diagram](https://github.com/user-attachments/assets/af034cd3-bf3e-4ac1-901e-5176c3f7b273)

## Installation

### Requirements

TODO

### Steps

TODO

## Contributing

This project is a personal learning endeavor, and contributions are not being accepted at this time.

## Developer Setup

### Requirements

- [devbox](https://www.jetify.com/devbox)
- [pre-commit](https://pre-commit.com/)

### Steps

1. Clone this repo and cd
2. Initialize the dev environment:

   ```sh
   devbox init
   ```

3. Start the dev environment:

   ```sh
   devbox shell
   ```

4. Install `pre-commit` hooks:

   ```sh
   pre-commit install
   ```

5. (Optional) Run pre-commit on all files:

   ```sh
   pre-commit run --all-files
   ```

## Usage

* SSH to an EC2 instance

   ```sh
   AWS_PROFILE="k8s_homelab" aws ec2-instance-connect ssh --instance-id i-07eb24daa48842f91 --os-user ubuntu --connection-type eice

   export AWS_PROFILE="k8s_homelab"
   ssh -i ~/.ssh/id_rsa_k8s_homelab ubuntu@i-07eb24daa48842f91 -o ProxyCommand='aws ec2-instance-connect open-tunnel --instance-id i-07eb24daa48842f91'
   ```

TODO: complete with "smoke tests"

## Authors and Acknowledgment

- **Hoarau Jerome** - [GitHub](https://github.com/hoaraujerome)

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. For more details, see the LICENSE file or visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

## Project Status

✅ **Phase 1 Completed**

The Kubernetes cluster is successfully deployed on AWS using `kubeadm` and self-managed EC2 instances. This phase included:

- Infrastructure as Code setup for 1 control plane node and 1 worker node
- End-to-end automation: AMI building (Packer + Ansible), infrastructure provisioning (Terraform), and cluster bootstrapping
- Secure access to the Kubernetes API server from the local machine
- Devbox is used to streamline the development environment, making it easier to work consistently across my personal workstations.

🚧 **Phase 2 is planned**, but its scope is yet to be defined.
