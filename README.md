# Homepage-R2-secfixes-dev-infra  
KEEPER 홈페이지 R2의 취약점, 버그 패치를 위한 개발 서버 인프라

## 배포 가이드  
Github Actions와 같은 빌드 서버를 사용하지 않고 로컬에서 빌드 후 이미지를 서버에 전달하여 실행하는 방식으로 구현되어있습니다.

### 첫 배포

1. **Caddyfile** 주소를 사용할 도메인 주소로 변경합니다.  
2. `.example.env`를 참고하여 `.env` 파일을 생성합니다.  
3. 배포할 서버에 **docker**와 **rsync**를 설치합니다.  
4. 본인 컴퓨터(빌드 및 배포를 진행할 로컬)에서 [unregistry](https://github.com/psviderski/unregistry)를 설치합니다.  
5. **rsync**를 이용하여 서버로 `build`를 제외한 현재 디렉토리에 있는 모든 폴더와 파일들을 전송합니다.  
   - 서버에 `/opt/Homepage-R2-secfixes-dev-infra/` 폴더를 만들어주세요.  
   - ```sh
     rsync -avhzP --exclude=".git" --exclude="build" --rsync-path="sudo rsync" -e 'ssh -i /home/user/.ssh/my_special_key' . user@remote.server:/opt/Homepage-R2-secfixes-dev-infra/
     ```  
6. `./build/back/build_back.sh` 및 `./build/front/build_front.sh`를 실행시켜서 도커 이미지를 생성합니다.  
   - 서버나 로컬 환경에 맞게 `--platform linux/amd64`를 수정해주세요.  
   - **Dockerfile**에서 또한 빌드 환경에 따라 설정해주세요.  
7. **unregistry**를 통하여 빌드한 도커 이미지들을 전달합니다.  
   - ```sh
     docker pussh homepage-back-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
     ```  
   - ```sh
     docker pussh homepage-front-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
     ```  
8. 서버에서 **docker compose**를 실행시킵니다.  
   - ```sh
     docker compose -f compose.yml up -d
     ```

> **참고**: 6~8은 `build_n_deploy.sh`를 실행함으로서 동일한 명령어들을 한 번에 실행할 수 있습니다.

### 그 후 배포

1. `./build/back/build_back.sh` 및 `./build/front/build_front.sh`를 실행시켜서 도커 이미지를 생성합니다.  
2. **unregistry**를 통하여 빌드한 도커 이미지들을 전달합니다.  
   - ```sh
     docker pussh homepage-back-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
     ```  
   - ```sh
     docker pussh homepage-front-r2:latest user@remote.server -i /home/user/.ssh/my_special_key
     ```  
3. 서버에서 **docker compose**를 실행시킵니다.  
   - ```sh
     docker compose -f compose.yml up -d
     ```

> **참고**: 1~3은 `build_n_deploy.sh`를 실행함으로서 동일한 명령어들을 한 번에 실행할 수 있습니다.

---

`myapp:latest` 수정
