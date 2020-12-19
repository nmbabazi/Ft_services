#avoir les permissions sur docker sans sudo
echo $USER | sudo -S chmod 666 /var/run/docker.sock

#############################################
minikube delete
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
#############################################


minikube start --vm-driver=docker #Spécification du pilote de machine virtuelle
sudo chown -R $USER $HOME/.kube $HOME/.minikube
eval $(minikube docker-env) #point the docker client to the machine's docker daemon

export CLUSTER_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
sed -i 's/172.17.0.2/'$CLUSTER_IP'/g' srcs/deployment/configmap.yaml
sed -i 's/172.17.0.2/'$CLUSTER_IP'/g' srcs/images/ftps/start.sh
sed -i 's/172.17.0.2/'$CLUSTER_IP'/g' srcs/images/nginx/nginx.conf
sed -i 's/172.17.0.2/'$CLUSTER_IP'/g' srcs/images/mysql/wordpress.sql

#metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
#On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f srcs/deployment/configmap.yaml

docker build -t my_mysql srcs/images/mysql/
docker build -t my_wordpress srcs/images/wordpress/
docker build -t my_nginx srcs/images/nginx/
docker build -t my_phpmyadmin srcs/images/phpmyadmin/
docker build -t my_influxdb srcs/images/influxdb/
docker build -t my_telegraf srcs/images/telegraf/
docker build -t my_grafana srcs/images/grafana/
docker build -t my_ftps srcs/images/ftps/

kubectl apply -f ./srcs/deployment

echo "#####info login######"
echo "PHPMYADMIN:   USER:root------MDP:password"
echo "GRAFANA:      USER:naila-----MDP:naila1234"
echo "FTPS:         USER:naila-----MDP:naila1234"

#########demarrer le dashboard########
minikube dashboard