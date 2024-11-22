# devtools

Some scripts that can help all devs to work.

## Kubernetes Proxy Orchestrator

- Map all services for Orchestrator
- You can use the localhost:${PORT}
- Ports will be "hardcoded", always the same port
- Please add a new Spring Profile "application-local.yml" and change to "localhost:${PORT}

## Kubernetes Proxy Construct

- Map all services in Construct Env
- Ports will be random mapped, please take care
- Please add a new Spring Profile "application-local.yml" and change to "localhost:${PORT}

## Tips

- clone the project
- go to your $HOME/.zshrc file or $HOME/.bashrc
- add the alias that can make it a command line on terminal, for example:
    ```
    alias proxyOrchestrator="cd ${PROJECT_FOLDER_REPLACE_HERE} && ./kubernetes_proxy_orchestrator.sh"
    ```
or:
    ```
    alias startProxyKubernetes="cd ${PROJECT_FOLDER_REPLACE_HERE} && ./kubernetes_proxy_orchestrator.sh"
    ```
or:
    ```
    alias startProxyConstruct="cd ${PROJECT_FOLDER_REPLACE_HERE} && ./kubernetes_proxy_construct.sh"
    ```

Concept:
alias ${THE_NAME_THAT_YOU_WANT_TO_TYPE_IN_TERMINAL}="${ALL_COMMAND_LINES_THAT_YOU_NEED}"