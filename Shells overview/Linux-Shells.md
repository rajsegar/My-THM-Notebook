# 🐧 Linux Shells

## What Is a Shell?
A shell is an interface between the user and the OS. CLI shells are more powerful, efficient, and resource-friendly than GUI.

## Essential Commands Cheatsheet

| Command | Purpose | Example |
|---|---|---|
| `pwd` | Print working directory | `pwd` → `/home/user` |
| `cd` | Change directory | `cd Desktop` |
| `ls` | List directory contents | `ls` |
| `cat` | Display file contents | `cat file.txt` |
| `grep` | Search pattern in file | `grep THM dictionary.txt` |
| `echo $SHELL` | Show current shell | `/bin/bash` |
| `cat /etc/shells` | List all installed shells | — |
| `chsh -s /usr/bin/zsh` | Permanently change default shell | — |

## Shell Types Comparison

| Feature | Bash | Fish | Zsh |
|---|---|---|---|
| Full Name | Bourne Again Shell | Friendly Interactive Shell | Z Shell |
| Default in Linux | ✅ Yes | ❌ No | ❌ No |
| Scripting | Extensive, widely compatible | Limited | Excellent (Bash + extras) |
| Tab Completion | Basic | Advanced (history-based) | Plugin-extensible |
| Spell Correction | ❌ No | ✅ Built-in | ✅ Yes |
| Syntax Highlighting | ❌ No | ✅ Built-in | ✅ Via plugins |
| Customization | Basic | Good (interactive tools) | Advanced (oh-my-zsh) |
| User Friendliness | Familiar/traditional | Most beginner-friendly | Highly customizable |

---

## 📝 Bash Scripting

### File Setup
```bash
nano script.sh        # Create script
chmod +x script.sh    # Give execute permission
./script.sh           # Run it
```

### Shebang (Required First Line)
```bash
#!/bin/bash
```

### Variables
```bash
#!/bin/bash
echo "Hey, what's your name?"
read name
echo "Welcome, $name"
```

### Loops
```bash
#!/bin/bash
for i in {1..10}; do
  echo $i
done
```

### Conditional Statements
```bash
#!/bin/bash
echo "Enter your name:"
read name
if [ "$name" = "Stewart" ]; then
  echo "Welcome Stewart! Secret: THM_Script"
else
  echo "Access denied."
fi
```

### Comments
```bash
# This is a comment — ignored at runtime
# Use comments on complex/major areas of the script
```

---

## 🔒 Full Example — Bank Locker Script
```bash
#!/bin/bash

# Define variables
username=""
companyname=""
pin=""

# Loop to collect 3 inputs
for i in {1..3}; do
  if [ "$i" -eq 1 ]; then
    echo "Enter your Username:"
    read username
  elif [ "$i" -eq 2 ]; then
    echo "Enter your Company name:"
    read companyname
  else
    echo "Enter your PIN:"
    read pin
  fi
done

# Validate all credentials
if [ "$username" = "John" ] && [ "$companyname" = "Tryhackme" ] && [ "$pin" = "7385" ]; then
  echo "Authentication Successful. You can now access your locker, John."
else
  echo "Authentication Denied!!"
fi
```
