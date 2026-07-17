# Argument mode

- Launch goad.py script (or goad.sh wrapper) with arguments

```bash
usage: goad.py [-h] [-t {install,check,start,stop,restart,destroy,status,snapshot,reset,show}] [-l LAB] [-p PROVIDER] [-ip IP_RANGE] [-m METHOD]
               [-i INSTANCE] [-e EXTENSIONS] [-a ANSIBLE_ONLY] [-r RUN_PLAYBOOK] [-d DISABLE_DEPENDENCIES]

Description : goad lab management console.

options:
  -h, --help            show this help message and exit
  -t, --task {install,check,start,stop,restart,destroy,status,snapshot,reset,show}
  -l, --lab LAB         lab to use (default: GOAD)
  -p, --provider PROVIDER
                        provider to use (default: vmware)
  -ip, --ip_range IP_RANGE
                        ip range to use (default: 192.168.56)
  -m, --method METHOD   deploy method to use (default: local)
  -i, --instance INSTANCE
                        use a specific instance (use default if not selected)
  -e, --extensions EXTENSIONS
                        extensions to use
  -a, --ansible_only ANSIBLE_ONLY
                        run only provisioning (ansible) on instance (-i) (for task install only)
  -r, --run_playbook RUN_PLAYBOOK
                        run only one ansible playbook on instance (-i) (for task install only)
  -d, --disable_dependencies DISABLE_DEPENDENCIES
                        disable_dependencies

Example :
 - Install GOAD on virtualbox : python3 goad.py -t install -l GOAD -p virtualbox
 - Launch GOAD interactive console : python3 goad.py
```