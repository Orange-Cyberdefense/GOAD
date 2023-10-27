# NINJA HACKER ACADEMY

<div align="center">
<img src="./files/wwwroot/Content/logo.jpeg" width="300px"/>
</div>

- NINJA HACKER ACADEMY (NHA) is written as a training challenge where GOAD was written as a lab with a maximum of vulns.
- You should find your way in to get domain admin on the 2 domains (academy.ninja.lan and ninja.hack)
- Starting point is on srv01 : 192.168.58.21

- Flags are disposed on each machine, try to grab all. Be careful all the machines are up to date with defender enabled.
- Some exploits needs to modify path so this lab is not very multi-players compliant (unless you do it as a team ;))
- Obviously do not cheat by looking at the passwords and flags in the recipe files, the lab must start without user to full compromise. 

- Install :

```bash
./goad.sh -t install -l NHA -p virtualbox -m docker
```

- Once install finish disable vagrant user to avoid using it :

```bash
./goad.sh -t disablevagrant -l NHA -p virtualbox -m docker
```

- Now do a reboot of all the machine to avoid unintended secrets stored : 

```bash
./goad.sh -t stop -l NHA -p virtualbox -m docker
./goad.sh -t start -l NHA -p virtualbox -m docker
```

And you are ready to play ! :)

- If you need to re-enable vagrant

```bash
./goad.sh -t enablevagrant -l NHA -p virtualbox -m docker
```

- If you want to create a write up of the chall, no problem, have fun. Please ping me on X (@M4yFly) or Discord, i will be happy to read it :)

Hint: No bruteforce, if not in rockyou do not waste your time and your cpu/gpu cycle.
