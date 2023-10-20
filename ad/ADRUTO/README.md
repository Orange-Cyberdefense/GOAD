# ADRUTO

<img src="./data/konoha.png" width="100px"/>

- ADRUTO is written as a training challenge where GOAD was written as a lab with a maximum of vulns.
- You should find your way in to get domain admin on the 2 domains (academy.konoha.fire and konoha.leaf)
- Starting point is on srv01 : 192.168.58.21

- Flags are disposed on each machine, try to grab all. Be careful all the machines are up to date with defender enabled.
- Some exploits needs to modify path so this lab is not very multi-players compliant (unless you do it as a team ;))
- Obviously do not cheat by looking at the passwords in the recipe files, the lab must start without user to full compromise.

- Install  :

```bash
./goad.sh -t install -l ADRUTO -p virtualbox -m docker
```

- Once install finish disable vagrant user to avoid cheat :

```bash
./goad.sh -t disablevagrant -l ADRUTO -p virtualbox -m docker
```

- If you need to re-enable vagrant

```bash
./goad.sh -t enablevagrant -l ADRUTO -p virtualbox -m docker
```
