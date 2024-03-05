FROM rockylinux/rockylinux:latest

# 필요한 패키지 설치
RUN dnf -y update && dnf -y install openssh-server passwd

# SSH 호스트 키 생성
RUN ssh-keygen -A

# root 사용자 비밀번호 설정 (보안을 위해 변경 필요)
RUN echo 'root:admin123!' | chpasswd

# SSH 서버 설정 (필요에 따라 수정)
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH 포트 노출
EXPOSE 22

# SSH 서버 실행
CMD ["/usr/sbin/sshd", "-D"]