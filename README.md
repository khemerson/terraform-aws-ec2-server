# terraform-aws-ec2-server

[![CI](https://github.com/khemerson/terraform-aws-ec2-server/actions/workflows/ci.yml/badge.svg)](https://github.com/khemerson/terraform-aws-ec2-server/actions/workflows/ci.yml)

Module Terraform qui déploie un serveur EC2 sur AWS avec son groupe de sécurité dédié :
SSH ouvert à un seul CIDR d'administration, et une liste explicite de ports TCP publics.

Il sert de support pédagogique pour la création d'infrastructures cloud en Infrastructure as Code :
un module court, lisible en une séance, qui montre les variables validées, les blocs dynamiques
et le cycle de vie `create_before_destroy`.

## Ce que le module crée

| Ressource | Rôle |
|---|---|
| `aws_security_group.this` | SSH (22/tcp) depuis `admin_cidr` uniquement ; un `ingress` par port de `open_ports`, ouvert à `0.0.0.0/0` ; sortie libre. Recréé **avant** destruction de l'ancien (`create_before_destroy`). |
| `aws_instance.this` | Instance EC2 attachée au groupe de sécurité, étiquetée `Name` et `Role` en plus de `tags`. |

## Prérequis

- Terraform **1.15.8** (version utilisée par la CI).
- Fournisseur `hashicorp/aws` **6.64.0**, figé par `.terraform.lock.hcl`.
- Pour `validate` : aucun compte AWS n'est nécessaire.
- Pour `plan` / `apply` : des identifiants AWS (variables d'environnement ou profil), une AMI et une paire de clés existantes dans la région choisie.

## Démarrage rapide : valider sans compte AWS

```bash
git clone https://github.com/khemerson/terraform-aws-ec2-server.git
cd terraform-aws-ec2-server/examples/basic
terraform init -backend=false
terraform validate
```

Résultat attendu : `Success! The configuration is valid.`

## Utilisation

```hcl
module "web" {
  source = "github.com/khemerson/terraform-aws-ec2-server"

  name       = "web"
  ami_id     = "ami-0123456789abcdef0" # à remplacer par une AMI de votre région
  key_name   = "my-keypair"            # paire de clés existante
  admin_cidr = "203.0.113.10/32"       # votre IP publique, jamais 0.0.0.0/0
  open_ports = [80, 443]

  tags = {
    Environment = "lab"
  }
}
```

L'exemple complet, avec le bloc `provider`, est dans [`examples/basic`](examples/basic).
Pour déployer réellement :

```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars   # puis renseigner vos valeurs
terraform init
terraform plan
terraform apply
terraform destroy                               # à la fin du lab
```

`terraform.tfvars` est ignoré par git : il ne doit jamais être versionné.

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `name` | `string` | — | Nom logique du serveur (web, monitoring…). |
| `ami_id` | `string` | — | Identifiant de l'AMI. |
| `instance_type` | `string` | `"t3.micro"` | Type d'instance EC2. |
| `key_name` | `string` | — | Nom de la paire de clés EC2. |
| `admin_cidr` | `string` | — | CIDR autorisé en SSH. **Refusé s'il vaut `0.0.0.0/0`** ou s'il n'est pas un CIDR valide. |
| `open_ports` | `list(number)` | `[]` | Ports TCP ouverts à tout Internet. |
| `tags` | `map(string)` | `{}` | Étiquettes ajoutées à l'instance. |

## Sorties

| Nom | Description |
|---|---|
| `public_ip` | Adresse IP publique de l'instance. |
| `instance_id` | Identifiant de l'instance. |
| `security_group_id` | Identifiant du groupe de sécurité. |

## Structure

```text
.
├── main.tf                      # groupe de sécurité + instance
├── variables.tf                 # entrées, avec validation de admin_cidr
├── outputs.tf                   # sorties
├── versions.tf                  # contraintes Terraform et fournisseur
├── .terraform.lock.hcl          # version exacte du fournisseur
├── examples/basic/              # appel du module, validable sans compte AWS
└── .github/workflows/ci.yml     # fmt, validate, gitleaks
```

## Intégration continue

À chaque push et pull request, la CI exécute :

- `terraform fmt -check -recursive` ;
- `terraform init -backend=false` puis `terraform validate`, à la racine et dans `examples/basic` ;
- `gitleaks` sur l'arbre de travail **et** sur tout l'historique git.

Les actions GitHub sont figées par SHA de commit, Terraform en 1.15.8, gitleaks en 8.30.1 (somme SHA256 vérifiée).

## Licence

[MIT](LICENSE) © 2026 Hemerson KOFFI
