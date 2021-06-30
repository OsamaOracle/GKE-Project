# GKE-Project
 This project fully automated on Terraform 

# Pre-requisites:
-	Terraform v0.13.5 must be installed on the machine
-	Google Cloud Authentication file must be present in root directory of Terraform script.


1.	First, create google cloud authentication service account, so Terraform can authenticate with Google Cloud to create resources. Ref link below : 
https://cloud.google.com/docs/authentication/getting-started#command-line.


2.	After getting the authentication.json file. Store it inside the Terrform Script directory where other files are present i.e. main.tf, variables.tf etc. 
3.	Now, let’s configure the variables used in the file, env.tfvars:  
-	region – used to tell Terraform in which region of GCP to create the cluster
-	credential_file – used to tell Terraform which file to use for authenticating with Google Cloud
-	env_name – used to define the Environment of our cluster, i.e. dev, test, stage, prod.
-	cluster_name – used to define the kubernetes cluster name to be created.
-	project_id – used to tell Terraform which project to deploy the Cluster inside GCP

4.	After, all these variables are configured, save the file and initialize terraform by using command : 
 	$ terraform init

5.	Once Terraform is initialized, let’s deploy the resources with the help of the below command : 
   	$ terraform apply --var-file=env.tfvars --auto-approve ; terraform apply --var-file=env.tfvars --target kubernetes_service.loadbalancer --auto-approve

6.	The above command will take some time to deploy the resources and will output the IP address in the end to access the application. 

If you want to destroy the created resources, you can simply use the below command: 
	$  terraform destroy --var-file=env.tfvars
