# Ansible Deployment

Applies Kubernetes manifests for the lab stack.

## Prerequisites
- `ansible-core >= 2.14`
- `kubectl` configured (KUBECONFIG exported or default at `~/.kube/config`).
- Install collection:
  ```sh
  ansible-galaxy collection install -r requirements.yml
  ```

## Run
```sh
cd ansible
ansible-playbook -i inventory.ini playbook.yaml
```

The playbook creates the `dev` namespace, applies ConfigMap/Secret, deploys Postgres, Redis, and the API, and uses the manifests from `../k8s`.
