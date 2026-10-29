# Automated Deployment of a Web Application using CI/CD, Terraform, Azure and Jenkins

**Name:** ________  **Reg. No.:** ________  **Course:** ________  **Date:** ________
**GitHub repository:** https://github.com/<your-username>/azure-devops-project

---

## 1. Objective

To design and implement a complete DevOps pipeline that automatically provisions infrastructure on Microsoft Azure using Terraform and automatically builds, tests and deploys a web application using a Jenkins CI/CD pipeline, triggered by commits to GitHub.

## 2. Tools Used

| Tool | Purpose |
|---|---|
| Microsoft Azure | Cloud platform hosting the infrastructure and web app |
| Terraform (azurerm provider) | Infrastructure as Code: creates all Azure resources |
| Jenkins | CI/CD automation server |
| GitHub | Version control and pipeline trigger source |
| Python Flask + gunicorn | Web application and production application server |
| nginx | Reverse proxy on port 80 |
| pytest | Automated tests run in the pipeline |
| Ubuntu 22.04 LTS | Operating system on the Azure VM |
| cloud-init | Automatic first-boot configuration of the VM |

## 3. Architecture Diagram

*(Insert `docs/architecture.png` here.)*

**Workflow explanation**
1. The developer pushes code to GitHub.
2. Jenkins detects the commit (webhook or Poll SCM every 2 minutes) and starts the pipeline.
3. **Checkout**: Jenkins pulls the latest code. **Build**: creates a Python virtual environment and installs dependencies. **Test**: runs pytest and publishes the JUnit report. **Package**: stamps the build number and commit ID into the app. **Deploy**: copies the code to the Azure VM over SSH (rsync), installs dependencies and restarts the `flaskapp` service. **Smoke test**: calls `/health` on the public IP to confirm the deployment.
4. Users access the application through the VM's public IP on port 80 (nginx -> gunicorn -> Flask).

## 4. Terraform Implementation

Resources created: Resource Group, Virtual Network, Subnet, Network Security Group (ports 22 and 80), Public IP, Network Interface, Linux Virtual Machine.

Design highlights:
- **Modular**: `modules/network` (VNet, subnet, NSG) and `modules/compute` (public IP, NIC, VM).
- **Variables with validation** and defaults; secrets and local values kept out of Git (`terraform.tfvars` is git-ignored).
- **Outputs**: public IP, app URL, SSH command.
- **State management**: local state by default, optional remote state in Azure Storage (`scripts/bootstrap_tfstate.sh`).
- **cloud-init** installs nginx and Python on first boot, so no manual configuration is needed.

*(Paste key snippets: `terraform/main.tf`, `modules/compute/main.tf`.)*

## 5. Jenkins Pipeline

*(Paste the `Jenkinsfile`.)*

Stages: Checkout -> Build -> Test -> Package -> Deploy to Azure VM -> Smoke Test. Triggers: `githubPush()` and `pollSCM('H/2 * * * *')`. Credentials are stored in the Jenkins credential store (never in code).

## 6. Screenshots

1. `terraform apply` output (resources created + outputs): *(screenshot)*
2. Azure Portal showing the resource group and its resources: *(screenshot)*
3. Jenkins pipeline stage view, all green: *(screenshot)*
4. Jenkins console output ending with `Finished: SUCCESS`: *(screenshot)*
5. Web application running at `http://<public-ip>`: *(screenshot)*
6. Continuous deployment proof: GitHub commit, new Jenkins build triggered automatically, and updated web page with new build number: *(screenshots)*

## 7. Observations

- Infrastructure that would take many manual clicks in the Azure Portal is created reproducibly in a few minutes with a single `terraform apply`, and can be removed completely with `terraform destroy`.
- Every commit automatically goes through build, test and deploy, so manual deployment errors are removed and the delivery cycle becomes short.
- The smoke test catches failed deployments immediately by verifying the live application.
- Issues faced and how they were solved: *(write your real ones here, e.g. region/SKU availability, SSH key format, missing plugin)*.

## 8. Conclusion

The project demonstrates a working end-to-end DevOps workflow: Infrastructure as Code with Terraform, continuous integration and continuous deployment with Jenkins, and automated delivery of a web application to Microsoft Azure triggered by code commits in GitHub. Possible future improvements: containerising the app with Docker, deploying to Azure App Service or AKS, adding HTTPS, using remote Terraform state with locking, and running Terraform itself from the Jenkins pipeline.
