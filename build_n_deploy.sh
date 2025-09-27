cd ./build/back && ./build_back.sh
cd .. && cd ..
cd ./build/front && ./build_front.sh
cd .. && cd ..

docker pussh homepage-back-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
docker pussh homepage-front-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
ssh user@remote.server -i /home/user/.ssh/my_special_key "cd /opt/Homepage-R2-secfixes-dev-infra/ && sudo docker compose -f compose.yml up -d"

