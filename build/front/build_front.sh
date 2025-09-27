if [ -d "Homepage-Front-R2-secfixes" ]; then
  echo "폴더가 이미 존재합니다. git pull을 실행합니다..."
  (cd Homepage-Front-R2-secfixes && git pull origin develop)
else
  echo "폴더가 없습니다. git clone을 실행합니다..."
  git clone -b develop --depth 1 "https://github.com/KEEPER31337/Homepage-Front-R2-secfixes.git" Homepage-Front-R2-secfixes
fi

DOCKER_BUILDKIT=1
docker build --platform linux/arm64/v8 -t homepage-front-r2:latest --build-arg REACT_APP_API_URL=https://api.keeper.cjaewon.com .