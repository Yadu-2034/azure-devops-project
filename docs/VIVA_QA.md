# Viva cheat sheet: questions you will probably be asked

**What is Terraform and why use it?** Infrastructure as Code tool. You describe the desired infrastructure in files; Terraform creates it. Repeatable, version-controlled, no manual portal clicking.

**Terraform workflow?** `init` (download provider) -> `validate` -> `plan` (preview changes) -> `apply` (create) -> `destroy` (delete).

**What is the Terraform state file?** `terraform.tfstate` is how Terraform remembers what it created. Never commit it (can contain secrets). Better practice: remote state in Azure Storage.

**Why modules?** Reusable, organised units. Mine: `network` (VNet/Subnet/NSG) and `compute` (Public IP/NIC/VM). The root module wires them together using outputs/inputs.

**Which Azure resources did you create?** Resource Group, Virtual Network, Subnet, NSG, Public IP, Network Interface, Linux VM.

**What does the NSG do?** Firewall. Allows SSH (22) for Jenkins/me and HTTP (80) for users, blocks everything else.

**What is cloud-init?** First-boot script supplied via `custom_data`. It installs nginx + Python and creates the systemd service, so the VM is ready for deployment without manual setup.

**What is CI vs CD?** CI: every commit is automatically built and tested. CD: every successful build is automatically deployed.

**Explain your Jenkinsfile.** Declarative pipeline with 6 stages: Checkout, Build, Test, Package, Deploy, Smoke Test. Triggers via `githubPush()` and `pollSCM`.

**What is Poll SCM vs webhook?** Poll SCM: Jenkins asks GitHub for changes on a schedule (every ~2 min). Webhook: GitHub notifies Jenkins instantly on push (needs Jenkins reachable from the internet).

**How does Jenkins reach the VM securely?** SSH key pair. Public key is injected into the VM by Terraform; private key is stored in Jenkins Credentials (`azure-vm-ssh`) and used with the SSH Agent plugin. No passwords in code.

**How is the app served?** nginx (port 80) reverse-proxies to gunicorn (port 5000) running Flask as a systemd service (auto-restarts).

**How do you know a deployment worked?** Smoke test stage calls `/health` on the VM, and the page shows the new build number.

**Why not use a real IP in the Jenkinsfile?** It is stored as a Jenkins credential, so the pipeline stays reusable and nothing environment-specific is in Git.

**What would you improve?** Docker containers, Azure App Service/AKS, HTTPS with a domain, remote state with locking, run Terraform from Jenkins, Slack/email notifications, blue-green deploys.

**How would you demonstrate continuous deployment?** Edit the page heading, `git push`, and watch Jenkins build automatically and the website change.
