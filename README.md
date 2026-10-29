# Automated Deployment of a Web Application using CI/CD, Terraform, Azure and Jenkins

A complete DevOps pipeline: **Terraform** provisions the Azure infrastructure, **Jenkins** builds, tests and deploys a **Flask** web app to the Azure VM, and every `git push` to **GitHub** triggers a redeploy automatically.

## Architecture

```mermaid
flowchart LR
    Dev[Developer] -- git push --> GH[GitHub repo]
    GH -- webhook / Poll SCM --> J[Jenkins]
    subgraph Pipeline
      J --> C[Checkout] --> B[Build] --> T[Test pytest] --> P[Package] --> D[Deploy rsync+ssh] --> S[Smoke test]
    end
    D -- SSH --> VM
    subgraph Azure["Azure (created by Terraform)"]
      RG[Resource Group] --- VNET[VNet + Subnet + NSG]
      VNET --- NIC[NIC + Public IP]
      NIC --- VM[Ubuntu VM: nginx -> gunicorn -> Flask]
    end
    User[Browser] -- HTTP :80 --> VM
```

## Repo layout

```
.
├── Jenkinsfile                  # CI/CD pipeline (Checkout, Build, Test, Package, Deploy, Smoke test)
├── app/                         # Flask web app + pytest tests
├── terraform/
│   ├── main.tf  variables.tf  outputs.tf  providers.tf  cloud-init.tpl
│   └── modules/
│       ├── network/             # VNet, Subnet, NSG (+ association)
│       └── compute/             # Public IP, NIC, Linux VM
├── scripts/bootstrap_tfstate.sh # optional: remote Terraform state in Azure Storage
└── docs/                        # report template + viva Q&A
```

## What to install (everything inside WSL2 Ubuntu on Windows, or any Ubuntu/Linux)

| Tool | Why |
|---|---|
| WSL2 + Ubuntu (Windows only) | Jenkins pipeline uses `sh`, so it needs Linux. Install: `wsl --install` in PowerShell, reboot |
| Azure account | Azure for Students (free credit) or any free trial |
| Azure CLI | `az login` so Terraform can create resources |
| Terraform | Infrastructure as code |
| Git + GitHub account | Version control |
| Java 17 + Jenkins | CI/CD server |
| Python 3, venv, pip, rsync | Build/test the app, copy files to the VM |

## Setup, step by step

### 0. Install tools (Ubuntu / WSL2 terminal)

```bash
sudo apt update
sudo apt install -y git curl unzip wget gnupg software-properties-common \
                    python3 python3-venv python3-pip rsync openssh-client openjdk-17-jre

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform (HashiCorp apt repo)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

az --version | head -1 ; terraform -version | head -1 ; java -version
```

If any install command fails, the official pages are the source of truth: learn.microsoft.com (Azure CLI), developer.hashicorp.com/terraform/install, jenkins.io/doc/book/installing.

### 1. Get the code onto GitHub

```bash
# create an EMPTY public repo on github.com first (e.g. azure-devops-project), then:
git init && git add . && git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/azure-devops-project.git
git push -u origin main
```

### 2. Log in to Azure and make an SSH key

```bash
az login --use-device-code            # open the link, enter the code
az account show                       # confirm the right subscription

ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key -N ""
```

### 3. Provision infrastructure with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars    # edit location / vm_size if needed
terraform init
terraform validate
terraform plan
terraform apply          # type: yes     (takes ~2-4 minutes)
```

At the end, Terraform prints outputs. **Screenshot this** and note the `public_ip_address`.
Wait ~3 minutes for the VM's first-boot script (installs nginx and Python) to finish. Test SSH:

```bash
ssh -i ~/.ssh/azure_vm_key azureuser@<PUBLIC_IP> "cloud-init status --wait"   # should print: status: done
```

### 4. Start Jenkins (easiest way, no systemd needed)

```bash
mkdir -p ~/jenkins && cd ~/jenkins
wget https://get.jenkins.io/war-stable/latest/jenkins.war
java -jar jenkins.war --httpPort=8080
```

Leave that terminal open. Open <http://localhost:8080> in your browser. The first-time admin password is printed in the terminal. Choose **Install suggested plugins**, create an admin user.

Then **Manage Jenkins -> Plugins -> Available plugins**: install **SSH Agent** (and make sure *Git*, *Pipeline*, *GitHub* are present). Restart if asked.

### 5. Add the two Jenkins credentials

**Manage Jenkins -> Credentials -> System -> Global -> Add Credentials**

| Kind | ID (must match exactly) | Value |
|---|---|---|
| SSH Username with private key | `azure-vm-ssh` | Username `azureuser`; Private key -> Enter directly -> paste output of `cat ~/.ssh/azure_vm_key` |
| Secret text | `azure-vm-ip` | the VM public IP from `terraform output public_ip_address` |

### 6. Create the pipeline job

1. **New Item** -> name `azure-webapp-pipeline` -> **Pipeline** -> OK
2. **Build Triggers**: tick **Poll SCM**, schedule `H/2 * * * *`
3. **Pipeline**: Definition = *Pipeline script from SCM*, SCM = *Git*, Repository URL = your GitHub repo, Branch = `*/main`, Script Path = `Jenkinsfile`
4. Save -> **Build Now**

All six stages should turn green. Open `http://<PUBLIC_IP>` in the browser, the web app is live. **Screenshot the Jenkins stage view and the website.**

### 7. Prove continuous deployment (do this live in the review)

Edit `app/templates/index.html` (change the heading text), then:

```bash
git add . && git commit -m "Change heading" && git push
```

Within ~2 minutes Jenkins starts a new build by itself, and the website updates with a new `build-N` version on the page.

### Webhook instead of polling (optional)

A GitHub webhook needs a public URL to Jenkins. Locally, run `ngrok http 8080` and add `https://<ngrok-url>/github-webhook/` under GitHub repo -> Settings -> Webhooks (content type `application/json`, event: push). Poll SCM is already enough for the assignment ("Webhooks **or** Poll SCM").

## Cleanup (avoid charges)

```bash
cd terraform && terraform destroy     # type: yes
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `terraform apply`: *SkuNotAvailable* / quota error | Change `vm_size` (try `Standard_B2s`) or `location` (try `southindia`, `eastus`, `westeurope`) in `terraform.tfvars`, apply again |
| `terraform apply`: *RequestDisallowedByPolicy* (student account) | Your subscription limits regions: use the region listed in the error message |
| Jenkins: `python3 -m venv` fails | `sudo apt install python3-venv` |
| Jenkins: `sshagent` not found | Install the **SSH Agent** plugin |
| Deploy stage: *Permission denied (publickey)* | Wrong key pasted in `azure-vm-ssh`. Paste the **private** key `~/.ssh/azure_vm_key` (starts with `-----BEGIN OPENSSH PRIVATE KEY-----`) |
| Browser shows *502 Bad Gateway* | App not deployed yet: run the Jenkins job. Or `ssh` in and check `sudo systemctl status flaskapp` |
| Browser can't connect at all | VM still booting (wait 3 min) or NSG/IP wrong: check `terraform output app_url` |
| Smoke test fails but app works | Increase `--retry` in the Jenkinsfile, gunicorn may need a few seconds |

## Rubric mapping

| Rubric item | Where it is covered |
|---|---|
| Terraform (modular, variables, outputs, state) | `terraform/modules/*`, `variables.tf` with validation, `outputs.tf`, optional remote state (`scripts/bootstrap_tfstate.sh`) |
| CI/CD pipeline (build, test, deploy) | `Jenkinsfile`: Checkout, Build, Test (pytest + JUnit report), Package, Deploy, Smoke test |
| Azure deployment | Ubuntu VM + nginx reverse proxy + gunicorn systemd service, configured automatically through cloud-init |
| Report | `docs/REPORT_TEMPLATE.md` (fill in screenshots, export to PDF) |
