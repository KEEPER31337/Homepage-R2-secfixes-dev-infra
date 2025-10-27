if [ -d "./Homepage-Back-R2-secfixes" ]; then
  echo "Homepage-Back-R2-secfixes 폴더가 이미 존재합니다. git pull 실행 중..."
  (cd ./Homepage-Back-R2-secfixes && git pull origin develop)
else
  echo "Homepage-Back-R2-secfixes 폴더가 없습니다. git clone 실행 중..."
  git clone -b develop --depth 1 "https://github.com/KEEPER31337/Homepage-Back-R2-secfixes.git" Homepage-Back-R2-secfixes
fi

DOCKER_BUILDKIT=1
docker build --platform linux/arm64/v8 -t homepage-back-r2:latest .