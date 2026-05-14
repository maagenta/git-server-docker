FROM alpine

RUN apk add --no-cache git openssh

# Create git user with git-shell
RUN adduser -D -s /usr/bin/git-shell git && \
    passwd -u git

# Create directory structure
RUN mkdir -p /home/git/.ssh /home/git/repos /home/git/trash && \
    chmod 700 /home/git/.ssh && \
    chown -R git:git /home/git && \
    ln -s /home/git/repos /repos

# Copy custom git-shell commands
COPY git-shell-commands/ /home/git/git-shell-commands/
RUN chmod +x /home/git/git-shell-commands/* && \
    chown -R git:git /home/git/git-shell-commands

# Configure sshd
RUN ssh-keygen -A && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    cp -r /etc/ssh /etc/ssh.bak

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

CMD ["/entrypoint.sh"]
