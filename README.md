Role Name
=========

This role creates files for using OpenID Connect with NGINX Plus in Kubernetes.  The role should be idempotent (it can run over itself detecting changes). The goal of the role is to allow you to automate multiple IDPs for OIDC in Kubernetes.  This involves generating the nginx-config.yaml and applying it afterwards (this role just generates the file for now).

**Note:** This role is still in active development. There may be unidentified issues and the role variables may change as development continues.

Requirements
------------

**Ansible**

This role was developed and tested with [maintained](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#release-status) versions of Ansible. Backwards compatibility is not guaranteed.

Instructions on how to install Ansible can be found in the [Ansible website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-with-pip) I suggest using pip or venv so you can keep your existing environment clean.

**NGINX Plus Ingress**

This role assumes you have built the NGINX Plus Ingress with R22 and added the nginx-plus-module-njs package as part of the install.  There is a sample file in files/DockerfileForPlusOIDC if you need a reference. The official instructions are on the [documentation page](https://docs.nginx.com/nginx-ingress-controller/installation/building-ingress-controller-image/).

**Kubernetes**

This role assumes you have already stood up Kubernetes.  This was tested with 1.15, 1.16 and 1.17 so far.

**OIDC IDP**

This role assumes you have already setup your OIDC and OAuth2 provider.  An older walkthrough on some of this is available [here](https://www.nginx.com/blog/nginx-plus-ingress-controller-for-kubernetes-openid-connect-azure-ad/#idp).

Role Variables
--------------

Variables are listed in the defaults/main.yml file and must be modified in vars/main.yml or in your playbook.  This role will not work with the default idp variables.  Most are self explanatory but you must add an idp section and the hostname for the first one should be default.

**Note:** You must define an idp for hostname: default.  I call this idp0 and the hostname: default.  This must be configured from your OIDC information.

Dependencies
------------

**Platform**

This should run on a linux OS, however I have run this on my MacBook Pro with success. Post issues for OS in the github issues section.

**Ansible**

No other Ansible Galaxy roles are needed at the present time.  You could build something more robust by adding kubernetes commands and the ingress build also.

Installation
------------

You have a couple options here:

You can install the role from galaxy and create a playbook like below

```bash
ansible-galaxy install magicalyak.ansible_role_nginx_ingress_oidc
```

You can Download the git repo and modify the vars as mentioned above (I usually add my customization to the playbook itself).

```bash
ansible-galaxy install git+https://github.com/magicalyak/ansible-role-nginx-ingress-oidc.git
#OR
git clone https://github.com/magicalyak/ansible-role-nginx-ingress-oidc.git
cd ansible-role-nginx-ingress-oidc
ansible-galaxy install -f -r requirements.yml
cd -
```

Example Playbook
----------------

If you clone this role, create a playbook called nginx-oidc-install-custom.yml and it will ignore it for git upload.

```yaml
---
- hosts: localhost
  gather_facts: false
  connection: local

  tasks:
    - include_role:
        name: magicalyak.ansible_role_nginx_ingress_oidc
      vars:
        oidc_files_location: "/home/centos/git/ansible-role-nginx-ingress-oidc/files"  # Where we place our generated files
        oidc_backup: true             # Save copies of previous files
        oidc_headless: true           # For multiple ingress keyvalue store sync (comment out if not desired)
        oidc_resolver: 8.8.8.8        # 8.8.8.8 is the default
        oidc_idps:
          idp0:                       # these names are placeholders, suggest to use idp$i where $i is an incremental number
                                      # You could use the hostname or the client_id if you want, just make this unique per group
            hostname: default         # make one of these default (this applies to any unmatched host as a catch-all)
            oidc_authz_endpoint: "http://127.0.0.1:8080/auth/realms/master/protocol/openid-connect/auth"
            oidc_token_endpoint: "http://127.0.0.1:8080/auth/realms/master/protocol/openid-connect/token"
            oidc_jwt_keyfile: "http://127.0.0.1:8080/auth/realms/master/protocol/openid-connect/certs"
            oidc_client_id: "a2b20239-2dce-4306-a385-ac9clientid"
            oidc_client_secret: "kn_3VLh]1I3ods*[DDmMxNmg8xxx"
            oidc_logout_redirect: "http://127.0.0.1:8080/auth/realms/master/protocol/openid-connect/logout"
            oidc_hmac_key: kn_3VLh]1I3ods*[DDmMxNmg8xxx
          idp1:
            hostname: cafe.nginx.net  # This only will apply the configuration to the host "cafe.nginx.net"
            oidc_authz_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/authorize"
            oidc_token_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/token"
            oidc_jwt_keyfile: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/discovery/v2.0/keys"
            oidc_client_id: "f66df7b0-7378-489a-a98d-clientid"
            oidc_client_secret: "PourSomeSecretsOnMeButDontUseThisOne"
            oidc_logout_redirect: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/logout"
            oidc_hmac_key: ThisHMACNeedsToBeUnique
          idp2:
            hostname: cafe.example.com
            oidc_authz_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/authorize"
            oidc_token_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/token"
            oidc_jwt_keyfile: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/discovery/v2.0/keys"
            oidc_client_id: "f66df7b0-7378-489a-a98d-clientid2"
            oidc_client_secret: "PourSomeSecretsOnMeButDontUseThisOne2"
            oidc_logout_redirect: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/logout"
            oidc_hmac_key: ThisHMACNeedsToBeUnique2

        oidc_kube_dns: coredns.kube-system.svc.k8s.nginx.net                        # Only change if customized or coredns is default
        oidc_headless_dns:  nginx-ingress-headless.nginx-ingress.svc.k8s.nginx.net  # Only change if customized
        oidc_keyval_size: 1M                          # keyval store size (1M)
        oidc_keyval_id_timeout: 1h                    # keyval id timeout (1h)
        oidc_keyval_refresh_timeout: 8h               # keyval refresh timeout (8h)
        ingress_container_pullsecret: regcred         # Used for dockerhub credentials (if undefined this is not used)
        ingress_allow_cidr: 0.0.0.0/0                 # Range for status page (if undefined this is disabled) - 0.0.0.0/0 is not secure change for production
        #ingress_prometheus:                          # Prometheus exporter - If not defined = disabled
        #  scrape: true
        #  port: 9113
        ingress_imagename: magicalyak/nginx-plus:OIDC # container image name
        ingress_pullpolicy: Always                    # container restart policy

```

License
-------

[Apache License, Version 2.0](https://github.com/magicalyak/ansible-role-nginx-ingress-oidc/blob/master/LICENSE)

Author Information
------------------

[Tom Gamull](https://github.com/magicalyak)
