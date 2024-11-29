# Argument mode

- Launch goad.py script (or goad.sh wrapper) with arguments

```bash
usage: goad.py [-h] [-t TASK] [-l LAB] [-p PROVIDER] [-ip IP_RANGE] [-m METHOD] [-i INSTANCE] [-e EXTENSIONS] [-a ANSIBLE_ONLY] [-r RUN_PLAYBOOK]

Description : goad lab management console.

optional arguments:
  -h, --help            show this help message and exit
  -t TASK, --task TASK  tasks available : (install/start/stop/restart/destroy/status/show)
  -l LAB, --lab LAB     lab to use (default: GOAD)
  -p PROVIDER, --provider PROVIDER
                        provider to use (default: vmware)
  -ip IP_RANGE, --ip_range IP_RANGE
                        ip range to use (default: 192.168.56)
  -m METHOD, --method METHOD
                        deploy method to use (default: local)
  -i INSTANCE, --instance INSTANCE
                        use a specific instance (use default if not selected)
  -e EXTENSIONS, --extensions EXTENSIONS
                        extensions to use
  -a ANSIBLE_ONLY, --ansible_only ANSIBLE_ONLY
                        run only provisioning (ansible) on instance (-i) (for task install only)
  -r RUN_PLAYBOOK, --run_playbook RUN_PLAYBOOK
                        run only one ansible playbook on instance (-i) (for task install only)

Example :
 - Install GOAD on virtualbox : python3 goad.py -t install -l GOAD -p virtualbox
 - Launch GOAD interactive console : python3 goad.py
```