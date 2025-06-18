# 🚀 Magento 2 Deploy Helper for DDEV

An interactive Bash script to simplify local Magento 2 deployments in a DDEV environment. It supports `setup:upgrade`, `di:compile`, `static-content:deploy`, cache management, and Xdebug toggling.

---

## 📁 Installation

Place the `deploy` script in the following DDEV path:

```
.ddev/commands/web/deploy
```

Make it executable:

```bash
chmod +x .ddev/commands/web/deploy
```

---

## ▶️ Usage

Run the command from your terminal:

```bash
ddev deploy [mode]
```

---

## ⚙️ Available Modes

| Command           | Action performed                                        |
|-------------------|---------------------------------------------------------|
| `s`, `staticonly` | Only static content deploy (`setup:static-content:deploy`) |
| `u`, `upgrade`    | Only `setup:upgrade`                                    |
| `c`, `compile`    | Only `setup:di:compile`                                 |
| `uc`, `nostatic`  | Upgrade + Compile                                       |
| `ucs`, `normal`   | Upgrade + Compile + Static (full mode)                  |
| `v`, `verbose`    | Detailed output (shows full command logs)               |
| `h`, `help`       | Show help                                               |

---

## 💡 Examples

```bash
ddev deploy ucs         # Runs upgrade, compile, and static deploy
ddev deploy uc v        # Runs upgrade and compile with verbose output
ddev deploy c           # Only compile
ddev deploy h           # Show help
```

---

## 🧠 What the script does

For each step, it performs:

- Temporary Xdebug deactivation
- Cleanup of folders:
  - `var/log/`
  - `var/cache/`
  - `var/view_preprocessed/`
  - `generated/code/`
  - `generated/metadata/`
- Runs Magento CLI commands:
  - `setup:upgrade`
  - `setup:di:compile`
  - `setup:static-content:deploy`
  - `cache:flush`
  - `cache:clean`
- Reactivates Xdebug
- Sets developer mode (`deploy:mode:set developer`)

---

## 📦 Requirements

- A working Magento 2 instance with DDEV
- `magento` CLI available inside the container
- Xdebug properly configured with DDEV

---

## 👨‍💻 Author

Script developed by **Andrea Gregorio Mastracchio**

---

## 📌 Extra Notes

To extend this script with `production` mode support, CI/CD integration, or file logging, feel free to contribute or contact the author.
