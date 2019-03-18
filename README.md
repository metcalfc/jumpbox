
This repo will create the following infrastructure using Terraform:

- One 512mb Droplets in the SFO datacenter running Ubuntu 18.04
- One DigitalOcean Cloud Firewall to lock down communication between the Droplets and the outside world

We will then use Ansible to run the following tasks on both Droplets:

- Update all packages
- Install the DigitalOcean monitoring agent, to enable resource usage graphs in the Control Panel
- Install the desired packages

Inspired by: https://github.com/do-community/terraform-ansible-demo

## Prerequisites

- **Git**
- **Terraform**
- **Ansible**
- **SSH Key**
- **Personal access token for the DigitalOcean API**

## Configure

Set the Personal access token in an environment variable.

```
export DIGITALOCEAN_TOKEN=<here>
```

Setup default variables in the `tfvars`.

```
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

With your username and DNS domain for the jumpbox.

Now we can initialize Terraform. This will download some information for the DigitalOcean Terraform _provider_, and check the configuration for errors.

```
$ terraform init
```

## Step 2 — Run Terraform and Ansible

We can provision the infrastructure with the following command:

```
$ terraform plan
$ terraform apply
```

Running Ansible to finish setting up the servers:

```
$ ansible-galaxy install -r requirements.yml
$ ansible-playbook -i inventory ansible.yml
```
