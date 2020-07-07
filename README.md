Ansible NGINX Ingress OIDC Role
=========

[![Ansible Role](https://img.shields.io/ansible/role/49368)](https://galaxy.ansible.com/magicalyak/ansible_role_nginx_ingress_oidc)
![Ansible Quality Score](https://img.shields.io/ansible/quality/49368)

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

**Role Installation**

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
        oidc_hostname: "localhost.example.com"
      idp1:
        hostname: cafe.nginx.net  # This only will apply the configuration to the host "cafe.nginx.net"
        oidc_authz_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/authorize"
        oidc_token_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/token"
        oidc_jwt_keyfile: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/discovery/v2.0/keys"
        oidc_client_id: "f66df7b0-7378-489a-a98d-clientid"
        oidc_client_secret: "PourSomeSecretsOnMeButDontUseThisOne"
        oidc_logout_redirect: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/logout"
        oidc_hmac_key: ThisHMACNeedsToBeUnique
        oidc_hostname: "login.microsoftonline.com"
      idp2:
        hostname: cafe.example.com
        oidc_authz_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/authorize"
        oidc_token_endpoint: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/token"
        oidc_jwt_keyfile: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/discovery/v2.0/keys"
        oidc_client_id: "f66df7b0-7378-489a-a98d-clientid2"
        oidc_client_secret: "PourSomeSecretsOnMeButDontUseThisOne2"
        oidc_logout_redirect: "https://login.microsoftonline.com/dd3dfd2f-6a3b-40d1-9be0-tenantid/oauth2/v2.0/logout"
        oidc_hmac_key: ThisHMACNeedsToBeUnique2
        oidc_hostname: "socat.default.svc.cluster.local"     # This is for a socat tunnel if you have a forward proxy

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
    ingress_type: deployment                      # deployment or replicaset
    ingress_deployment_count: 1                   # number of ingress controllers
    ingress_imagename: magicalyak/nginx-plus:OIDC # container image name
    ingress_pullpolicy: Always                    # container restart policy
    # socat_enable: true
    # socat_domain: login.microsoftonline.com:443
    # socat_namespace: external
    # socat_proxy_ip: 10.233.65.4
    # socat_proxy_port: 3128
    # socat_port: 443

  tasks:
    - include_role:
        name: magicalyak.ansible_role_nginx_ingress_oidc

```

Kubernetes Process
------------------

**Verify Files**

Use the files in ./files to configure the ingress controller
You should have 4 or 5 files depending on your options.

```bash
ansible % ls -la files                                                                                                                              R22-k8s
total 112
drwxr-xr-x  10 tom.gamull  staff    320 Jun 17 15:57 .
drwxr-xr-x   7 tom.gamull  staff    224 Jun 17 15:54 ..
-rw-r--r--   1 tom.gamull  staff    239 Jun 17 15:57 headless.yaml
-rw-r--r--   1 tom.gamull  staff  18162 Jun 17 15:57 nginx-config.yaml
-rw-r--r--   1 tom.gamull  staff   2081 Jun 17 15:57 nginx-plus-ingress.yaml
-rw-r--r--   1 tom.gamull  staff  11248 Jun 17 15:57 openid_connect.js
-rw-r--r--   1 tom.gamull  staff   3850 Jun 17 15:57 openid_connect.server_conf
```

**Create Kubernetes Ingress Resources**

Modify the nginx-plus-ingress.yaml if needed for proxy settings, etc.
Modify the nginx-plus-service.yaml in the kubernetes-ingress/deployments/service directory as appropriate
Create the ingress resource as normal but specify the nginx-config.yaml located here
Create the configmaps (these shouldn't change after you import the first time)

**First Time Install**

```bash
NGINX_K8S_GIT_DIR=/home/centos/git/kubernetes-ingress
NGINX_K8S_OIDC_DIR=/home/centos/nginc-openid-connect
cd $NGINX_K8S_GIT_DIR/deployments
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/vs-definition.yaml
kubectl apply -f common/vsr-definition.yaml
kubectl apply -f common/ts-definition.yaml
kubectl apply -f common/gc-definition.yaml
kubectl apply -f common/global-configuration.yaml
cd $NGINX_K8S_OIDC_DIR
kubectl apply -f nginx-config.yaml
kubectl create configmap -n nginx-ingress openid-connect.js --from-file=openid_connect.js
kubectl create configmap -n nginx-ingress openid-connect.server-conf --from-file=openid_connect.server_conf
kubectl apply -f nginx-plus-ingress.yaml
cd $NGINX_K8S_GIT_DIR/deployments
kubectl apply -f service/nginx-plus-service.yaml  # Make sure this exists and you modified it
cd $NGINX_K8S_OIDC_DIR
```

**Previous Install**

Uncomment lines if you're upgrading the ingress controller from an earlier version.

```bash
NGINX_K8S_GIT_DIR=/home/centos/git/kubernetes-ingress
NGINX_K8S_OIDC_DIR=/home/centos/nginx-openid-connect
#cd $NGINX_K8S_GIT_DIR/deployments
#kubectl apply -f common/ns-and-sa.yaml
#kubectl apply -f rbac/rbac.yaml
#kubectl apply -f common/vs-definition.yaml
#kubectl apply -f common/vsr-definition.yaml
#kubectl apply -f common/ts-definition.yaml
#kubectl apply -f common/gc-definition.yaml
#kubectl apply -f common/global-configuration.yaml
cd $NGINX_K8S_OIDC_DIR
kubectl apply -f nginx-config.yaml
#kubectl apply -f nginx-plus-ingress.yaml
```

**Configure your applications**

Once you finish you can create an application like the cafe example

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: cafe-ingress
  annotations:
    custom.nginx.org/oidc:  "on"
    spec:
  tls:
  - hosts:
    - cafe.nginx.net
    secretName: cafe-secret
  rules:
  - host: cafe.nginx.net
    http:
      paths:
      - path: /tea
        backend:
          serviceName: tea-svc
          servicePort: 80
      - path: /coffee
        backend:
          serviceName: coffee-svc
          servicePort: 80
```

**Exposing JWT Claims in the application**

Use something similar to below:

```yaml
---
- hosts: localhost
  gather_facts: false
  connection: local
  vars:
    replace_http_custom: True
    apply_nginx_config: False
    oidc_files_location: "."  # Where we place our generated files
    oidc_backup: false            # Save copies of previous files
    oidc_headless: true           # For multiple ingress keyvalue store sync (comment out if not desired)
    #oidc_external_status_address: 172.16.186.100
    oidc_resolver: 8.8.8.8
    oidc_idps:
      idp0:                       # these names are placeholders, suggest to use idp$i where $i is an incremental number
                                  # You could use the hostname or the client_id if you want, just make this unique per group
        hostname: default         # make one of these default
        oidc_authz_endpoint: "https://##REPLACEME##/authorize"
        oidc_token_endpoint: "https://##REPLACEME##/token"
        oidc_jwt_keyfile: "https://##REPLACEME##/keys"
        oidc_client_id: "##CLIENTID##"
        oidc_client_secret: "##SECRET##"
        oidc_logout_redirect: "https://##REPLACEME##/logout"
        oidc_hmac_key: vC5FabzvYvFZFBzxtRCYDYX+
      idp1:
        hostname: cafe.nginx.net
        oidc_authz_endpoint: "https://##REPLACEME##/authorize"
        oidc_token_endpoint: "https://##REPLACEME##/token"
        oidc_jwt_keyfile: "https://##REPLACEME##/keys"
        oidc_client_id: "##CLIENTID##"
        oidc_client_secret: "##SECRET##"
        oidc_logout_redirect: "https://##REPLACEME##/logout"
        oidc_hmac_key: vC5FabzvYvFZFBzxtRCYDYX+
      idp2:
        hostname: cafe.example.com
        oidc_authz_endpoint: "https://##REPLACEME##/authorize"
        oidc_token_endpoint: "https://##REPLACEME##/token"
        oidc_jwt_keyfile: "https://##REPLACEME##/keys"
        oidc_client_id: "##CLIENTID##"
        oidc_client_secret: "##SECRET##"
        oidc_logout_redirect: "https://##REPLACEME##/logout"
        oidc_hmac_key: vC5FabzvYvFZFBzxtRCYDYX+
    oidc_keyval_size: 1M                          # keyval store size (1M)
    oidc_keyval_id_timeout: 1h                    # keyval id timeout (1h)
    oidc_keyval_refresh_timeout: 8h               # keyval refresh timeout (8h)
    ingress_type: deployment                      # deployment or replicaset
    ingress_deployment_count: 1                   # number of ingress controllers
    #ingress_container_pullsecret: regcred         # Used for dockerhub credentials (if undefined this is not used)
    ingress_allow_cidr: 0.0.0.0/0                 # Range for status page (if undefined this is disabled) - 0.0.0.0/0 is not secure change for production
    #ingress_prometheus:                          # Prometheus exporter - If not defined = disabled
    #  scrape: true
    #  port: 9113
    ingress_imagename: magicalyak/nginx-plus:OIDC # container image name
    ingress_pullpolicy: Always                    # container restart policy

  tasks:
    - include_role:
        name: magicalyak.ansible_role_nginx_ingress_oidc

    # This converts the preffered username (email) into a username by stripping off the @domain.com
    - name: Add custom variables to nginx-config.yml HTTP Ingress context
      blockinfile:
        path: "{{ oidc_files_location }}/nginx-config.yaml"
        insertafter: "^.{4}js_import oidc from conf.d/openid_connect.js;$"
        block: |2
              map $jwt_claim_preferred_username $jwt_sample1 {
                default $jwt_claim_preferred_username;
                ~^(?<username>.*)@(?<domain>.*)$ "${username}";
              }
        marker: "    # {mark} ANSIBLE MANAGED BLOCK"
      when: replace_http_custom

    - name: Apply nginx-config.yaml
      k8s:
        state: present
        src: "{{ oidc_files_location }}/nginx-config.yaml"
      when: apply_nginx_config
```

Then in your application ingress add some header values from the jwt claim. Please not these are exposed to the upstream server and not the end user (you won't see these in developer mode on chrome, but your upstream applicaiton will).

```yaml
# This is the application ingress file for a sample application
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: cafe-ingress
  annotations:
    custom.nginx.org/oidc:  "on"
    nginx.org/location-snippets: |
      proxy_set_header username $jwt_claim_sub;
      proxy_set_header jwt-email $jwt_claim_email;
      proxy_set_header jwt-username $jwt_claim_preferred_username;
      proxy_set_header jwt-name $jwt_claim_name;
      proxy_set_header jwt-aud $jwt_claim_aud;
      proxy_set_header jwt-firstname $jwt_claim_given_name;
      proxy_set_header jwt-lastname $jwt_claim_family_name;
      proxy_set_header jwt-sample1 $jwt_sample1;
spec:
  tls:
  - hosts:
    - cafe.nginx.net
    secretName: cafe-secret
  rules:
  - host: cafe.nginx.net
    http:
      paths:
      - path: /tea
        backend:
          serviceName: tea-svc
          servicePort: 80
      - path: /coffee
        backend:
          serviceName: coffee-svc
          servicePort: 80
```

**Update IDPs**

Simply run the playbook again and it will generate a new nginx-config.yml file (you'll see it in yellow as changed)
Then just apply the file and you'll only need to configure the app ingress.
This should be able to be automated quite easily.

```bash
cd /home/centos/nginx-openid-connect
vim nginx-oidc-install-custom.yml # Add the new app and IDP
ansible-playbook nginx-oidc-install-custom.yml
kubectl apply -f nginx-config.yml
```

License
-------

[Apache License, Version 2.0](https://github.com/magicalyak/ansible-role-nginx-ingress-oidc/blob/master/LICENSE)

Author Information
------------------

[Tom Gamull](https://github.com/magicalyak)
