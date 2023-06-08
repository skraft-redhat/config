# Enterprise Contract Configuration Files

This repo contains a set of `policy.yaml` files which can be used with
Enterprise Contract and the Red Hat Trusted Application Pipeline.

The policy configuration files are:

### Default

Includes rules for levels 1, 2 & 3 of SLSA v0.1.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//default`
* Source: [default/policy.yaml](https://github.com/enterprise-contract/config/blob/main/default/policy.yaml)

### Minimal

Include a minimal set of basic checks.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//minimal`
* Source: [minimal/policy.yaml](https://github.com/enterprise-contract/config/blob/main/minimal/policy.yaml)

### SLSA1

The minimal rules plus the rules for level 1 of SLSA v0.1.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//slsa1`
* Source: [slsa1/policy.yaml](https://github.com/enterprise-contract/config/blob/main/slsa1/policy.yaml)

### SLSA2

The minimal rules plus the rules for levels 1 & 2 of SLSA v0.1.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//slsa2`
* Source: [slsa2/policy.yaml](https://github.com/enterprise-contract/config/blob/main/slsa2/policy.yaml)

### SLSA3

The minimal rules plus the rules for levels 1, 2 & 3 of SLSA v0.1.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//slsa3`
* Source: [slsa3/policy.yaml](https://github.com/enterprise-contract/config/blob/main/slsa3/policy.yaml)

### Everything

Include every rule in the default policy source.

* URL for Enterprise Contract: `github.com/enterprise-contract/config//everything`
* Source: [everything/policy.yaml](https://github.com/enterprise-contract/config/blob/main/everything/policy.yaml)

## See also

* [Policy Rule Documentation](https://enterprisecontract.dev/docs/ec-policies/release_policy.html)
* [Getting Started with Enterprise Contract &amp; Red Hat Trusted Application Pipeline](https://enterprisecontract.dev/docs/user-guide/main/getting-started.html)
