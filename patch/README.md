# open-audit-patch
Patching open audit code for updates and fixes

# Patch Installation Instructions

## Overview

This patch will replace specific PHP files in the Open-Audit installation and restart the Apache service. The patch includes a script that will handle the backup of existing files, application of the patch, and restarting the Apache service.

## Steps to Apply the Patch

### 1. Extract the Patch Files

Download the `open-audit-patch.tar.gz` file and extract it:

```sh
tar -xzvf open-audit-patch.tar.gz
```

### 2. Navigate to the Patch Directory

Change to the patch directory:

```sh
cd open-audit-patch
```

### 3. Mark the Script as Executable

Ensure the patch script is executable:

```sh
chmod +x install.sh
```

### 4. Run the Patch Script

Execute the patch script with superuser privileges:

```sh
sudo ./install.sh
```

### 5. Verify the Patch

The script will provide verbose output, indicating the status of the backup, patch application, and Apache service restart. Ensure that there are no errors and that the Apache service is running.

## Additional Notes

- Ensure that you have open audit version 5 or later already installed.
- The script will automatically create a backup of the files specified for backup.
- If you encounter any issues, please contact support with the log output from the script.

# Create Build (for developers)

To create a build to share with others, run this command from within the patch directory:

```sh
cd ..
tar --exclude='.git' --exclude='.gitignore' --exclude='*.tar.gz' -czvf open-audit-patch.tar.gz open-audit-patch/

```
Feel free to adjust the name `open-audit-patch.tar.gz` if needed.
