#!/bin/bash

# Copyright © 2024 Bitcrush Testing

# Function to prompt for input and read the response
prompt_for_input() {
    local prompt_message="$1"
    local input_variable_name="$2"
    # shellcheck disable=SC2229
    read -rp "$prompt_message: " "$input_variable_name"
}

install_github_runner() {
    echo "Installing GitHub runner..."
    RUNNER_DIR=${HOME}/actions-runner

    if [ -d "${RUNNER_DIR}" ] 
    then
        echo "GitHub runner is already installed."
        read -rp "Do you want to overwrite it? (yes/no) " yn

        case $yn in 
	        yes ) echo "Ok, proceeding";;
	        no ) echo "Not installing GitHub runner";
		        return;;
	        * ) echo "Invalid response. Not installing Github runner.";
		        return;;
        esac
    fi 
    rm -rf "${RUNNER_DIR}"
    mkdir -p "${RUNNER_DIR}" && cd "${RUNNER_DIR}"
    echo "Install folder: ${RUNNER_DIR}"
    curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
    echo "9e883d210df8c6028aff475475a457d380353f9d01877d51cc01a17b2a91161d  actions-runner-linux-x64-2.317.0.tar.gz" | shasum -a 256 -c
    tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz
    sudo ./bin/installdependencies.sh

    # Prompt for necessary inputs
    prompt_for_input "Enter your GitHub token" GH_TOKEN
    prompt_for_input "Enter the GitHub repository URL (e.g., https://github.com/user)" GH_URL
    prompt_for_input "Enter the GitHub runner name" GH_RUNNER_NAME
    # Configuring the GitHub runner
    ./config.sh remove --token "$GH_TOKEN"
    ./config.sh --url "$GH_URL" --token "$GH_TOKEN" --name "$GH_RUNNER_NAME" --work "${RUNNER_DIR}/_work" --unattended --replace
  
    # Create the systemd service file
    SERVICE_FILE="/etc/systemd/system/github-runner.service"
    sudo rm -f "${SERVICE_FILE}"
    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=$RUNNER_DIR
ExecStart=$RUNNER_DIR/run.sh
Restart=always
RestartSec=10
StartLimitInterval=600
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd configuration
    sudo systemctl daemon-reload

    # Enable and start the service
    sudo systemctl enable github-runner.service
    sudo systemctl start github-runner.service

    # Verify the service status
    sudo systemctl status github-runner.service
}

install_github_cli() {
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
}

install_python() {
    sudo apt update && sudo apt install -y \
        curl \
        git \
        jq \
        tree \
        python3 \
        python3-pip \
        python3-pytest \
        chrpath \
        lz4 \
        && sudo apt-get clean
}

install_repo() {
    mkdir -p ~/bin
    export PATH=~/bin:$PATH
    curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
}

# Main script execution
set -e
USER_ID=$(id -u)

if [[ "$USER_ID" -eq 0 ]] && [[ -z "$RUNNER_ALLOW_RUNASROOT" ]]; then
    echo "Must not run with sudo"
    exit 1
fi

install_github_runner
if ! command -v gh &> /dev/null; then
    install_github_cli
fi

if ! command -v repo >/dev/null 2>&1; then
    install_repo
fi
