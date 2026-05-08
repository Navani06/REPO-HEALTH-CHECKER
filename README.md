# 🏥 Repo Health Checker

[![Repo Health Check](https://github.com/USERNAME/REPO_NAME/actions/workflows/check.yml/badge.svg)](https://github.com/USERNAME/REPO_NAME/actions/workflows/check.yml)

## Overview

**Repo Health Checker** is a professional DevOps project that automatically validates repository quality. It acts as an automated CI (Continuous Integration) gate, ensuring that no bad code, missing documentation, or leaked secrets make it into the repository. 

Whenever a developer pushes code or opens a Pull Request, a GitHub Action automatically runs a Bash script to inspect the repository. If it fails, the process is blocked.

---

## 🛡️ Why CI/CD Matters

In professional software engineering, **Continuous Integration and Continuous Deployment (CI/CD)** are standard practices.
- **Catches Mistakes Early:** Automated checks find missing files or leaked secrets before human reviewers.
- **Enforces Standards:** It keeps documentation and commit history clean.
- **Saves Time:** It runs in seconds, accelerating the review process.
- **Security:** It acts as a safety net against accidentally exposing credentials like `.env` or `*.pem` files.

---

## ✅ Validation Checks

The health checker (`check.sh`) performs the following strict validations:

| Check | What It Does | Why It Matters |
|---|---|---|
| **README Exists** | Verifies `README.md` is present | Every project needs documentation to be usable. |
| **README Length** | Ensures README has more than 5 lines | Prevents placeholder or empty documentation. |
| **Gitignore Exists** | Verifies `.gitignore` is present | Keeps junk files out of the repository. |
| **Secret Detection** | Scans for `.env`, `*.pem`, `*.key`, `secrets.txt` | Prevents accidental credential leaks (Security). |
| **Commit Messages** | Checks that recent commit messages have >5 words | Encourages detailed and meaningful Git history. |

---

## ⚙️ How the GitHub Action Works

This project uses a standard GitHub Actions CI pipeline:

1. A developer pushes code or opens a Pull Request.
2. The GitHub Action workflow (`.github/workflows/check.yml`) is triggered.
3. A cloud-hosted `ubuntu-latest` runner checks out the repository.
4. The workflow makes the `check.sh` script executable (`chmod +x`).
5. The Bash script runs all validation checks.
6. The CI gate passes (`exit 0`) or fails (`exit 1`) based on the outcome.

### Example Scenarios

- **Success Scenario:** You commit a descriptive message, add a `.gitignore`, and have a long `README.md`. The pipeline logs **"🎉 ALL CHECKS PASSED"** and allows the code to be merged.
- **Failure Scenario:** You accidentally commit a `secrets.txt` file. The pipeline immediately halts, logs **"🚫 CHECKS FAILED"**, and blocks the Pull Request until you remove the file and push again.

---

## 📁 Repository Structure

```text
repo-health-checker/
├── .github/
│   └── workflows/
│       └── check.yml        # The CI pipeline definition
├── check.sh                 # Core bash validation script
├── README.md                # Project documentation
└── .gitignore               # Files excluded from Git
```

---

## 🚀 How to Test Locally

You can run the health checker on your own machine before pushing to GitHub:

```bash
# Make the script executable
chmod +x check.sh

# Run the script
./check.sh
```

---

## 🔮 Future Improvements (Week 2 Ideas)

- Add a check to enforce branch naming conventions (e.g., `feature/*`, `bugfix/*`).
- Add a linting step for Python or Node.js code.
- Implement automated spell-checking for the README.
- Post a comment on the Pull Request with the failure details.
