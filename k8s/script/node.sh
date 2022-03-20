#!/bin/bash
sudo rsync -av -e "ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa" vagrant@10.10.0.10:/home/vagrant/config/* /home/vagrant/

/bin/bash /home/vagrant/join.sh -v

sudo -i -u vagrant bash << EOF
mkdir -p /home/vagrant/.kube
sudo cp -i /home/vagrant/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
NODENAME=$(hostname -s)
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker-new
EOF

sudo systemctl restart systemd-resolved
sudo systemctl restart kubelet

rm -R /home/vagrant/.ssh/id_rsa