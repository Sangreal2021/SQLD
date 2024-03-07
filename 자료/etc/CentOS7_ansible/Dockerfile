# CentOS 7 공식 이미지 사용
FROM ansible/centos7-ansible:latest

# 필요한 패키지 설치, 여기서는 openssh-server와 sudo 패키지를 설치합니다.
RUN yum -y update && \
    yum -y install openssh-server sudo && \
    yum clean all

# SSH를 위한 기본 설정
# SSH 호스트 키 생성
RUN ssh-keygen -A

# root 사용자 비밀번호 설정
RUN echo 'root:admin123!' | chpasswd

# SSH 서버 설정 - 비밀번호 인증 허용
RUN sed -i 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH 포트 노출
EXPOSE 22

# SSH 서비스 시작
CMD ["/usr/sbin/sshd", "-D"]