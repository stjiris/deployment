# packer

VM Image based on Ubuntu Server 22.04 with Docker

Install packer:

```
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install packer
```

Install Ansible:

```
$ apt-get install --no-install-recommends ansible
```

Reproduce the build by running the following:

```
$ cp examples.variables.pkrvars.hcl variables.pkrvars.hcl
$ make all
```
