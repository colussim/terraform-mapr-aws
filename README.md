Installing Kubernetes on AWS and HPE Ezmeral Data Fabric File Store with Terraform and kubeadm


## What is HPE Ezmeral Data Fabric ?

HPE Ezmeral Data Fabric, part of the HPE Ezmeral software portfolio, uses innovative technology originally developed as the MapR Data Platform (MapR Technologies was acquired by HPE in 2019). As a unifying software technology, the HPE Ezmeral Data Fabric delivers highly scalable data storage, access, management and movement across your enterprise, from the edge to the cloud, all within the same security system and with superb reliability.
HPE Ezmeral Data Fabric File Store is a distributed filesystem for data storage, data management, and data protection. File Store supports mounting and cluster access via NFS and FUSE-based POSIX clients (basic, platinum, or PACC) and also supports access and management via HDFS APIs.
You can manage your clusters from the Managed Control System (web console) and monitor them using HPE Ezmeral Data Fabric Monitoring. 

![mapr, the HPE Ezmeral Data Fabric](/images/MapR-XD-Architectural_Graphic.png)

This repository allows to create a 4 nodes kubernetes cluster (1 master and 3 workers) on AWS, 
This repository allows you to create a kubernetes cluster 4 nodes (1 master and 3 workers) on AWS, it includes 2 phases:
 - Deployment of centos 8.3 instances :
    - creation of a DNS domain : **datafabric02.local** (defined in the **variables.tf** file)
    - register nodes in the domain 
 - Deployment of HPE Ezmeral Data Fabric 6.2.x

## Infra
![infra, the Kubernetes infra](/images/archi.png)

## Prerequisites

Before you get started, you’ll need to have these things:
* Terraform > 0.13.x
* kubectl installed on the compute that hosts terraform
* An AWS account with the IAM permissions
* AWS CLI : [the AWS CLI Documentation](https://github.com/aws/aws-cli/tree/v2){:target="_blank" }
* GO language

## Initial setup

The source directory contains two GO programs (**PutReverseIP.go** and **ReverseIP.go**) that are used by the Terraform master and worker deployment scripts to generate the reverse ip addresses and the **nodehost.json** file (in directory **k8sdeploy-scripts**).
You may need to recompile them , so you will need GO. After the compilation it will be necessary to copy the binary in the directory: **k8sdeploy-scripts**


Clone the repository and install the dependencies:

```
$ git clone https://github.com/colussim/terraform-mapr-aws.git
$ cd terraform-mapr-aws
```

We will immediately create a dedicated ssh key pair to connect to our AWS EC2 instances.

```
$ mkdir ssh-keys
$ ssh-keygen -t rsa -f id_rsa_aws
$ ssh-keygen -t rsa -f id_rsa_aws
```

We now have two files id_rsa_aws and id_rsa_aws.pub in our ssh-keys directory.

Let’s deploy our infrastructure :

Use terraform init command in terminal to initialize terraform and download the configuration files.


```
$ terraform init
```


