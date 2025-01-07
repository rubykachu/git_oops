---
### Ruby Gem Implementation Request: **`git_oops`**

---

#### **Overview**
- **Gem Name**: `git_oops`
- **Alias**: `goops` for ease of use.
- **Main Objective**: Provide an interactive interface for users to safely and conveniently recover deleted commits in Git.
- **Primary Command**: `goops reset` to restore deleted commits.
- **Future Expansion**: Sub-commands will be developed to extend functionality.

---

#### **Feature Details**

**1. Command `goops reset`:**
- **Description**: Main sub-command to restore deleted commits.
- **Interactive Interface (UI/UX)**:
  - Displays a list of commits (default: last 20 commits from `git reflog`).
  - Supports navigation using arrow keys (up/down) to select the desired commit for restoration.
  - After selecting a commit, offers two options:
    1. **Save the current state** before restoring.
    2. **Directly restore** without saving.
  - Warns users if they choose not to save, to prevent potential data loss.

**2. Command Syntax:**
```
goops reset [options]
```

**Options:**
- `--limit <number>`: Number of commits to display (default: 20).
- `--search <keyword>`: Search for commits by keyword in the message.
- `--no-warning`: Skip the warning when restoring directly.

Example Usage:
```
goops reset --limit 30
goops reset --search "fix bug"
goops reset --no-warning
```

---

#### **User Interface**

**3.1. Display Commit List:**
```
Select a commit to restore (use arrow keys to navigate):
> 1. abc1234 - Commit message 1 [2 hours ago]
  2. def5678 - Commit message 2 [4 hours ago]
  3. ghi9012 - Commit message 3 [1 day ago]
  ...
```

**3.2. After Selecting a Commit:**
```
You selected: abc1234 - Commit message 1 [2 hours ago]

Options:
1. Save current source code state before restoring (recommended).
2. Restore directly without saving.

Enter your choice (1/2):
```

**3.3. Warning for Unsaved State:**
```
⚠️ WARNING: You are about to reset your code without saving the current state.
This action is irreversible and may lead to data loss.

Do you want to continue? (Y/n):
```

**3.4. Completion Message:**
```
✅ SUCCESS: The commit has been successfully restored!
```

---

#### **Color Scheme**
- **Yellow**: Display warnings.
- **Green**: Display success messages.
- **White/Gray**: General informational text.
- **Blue**: Highlight selected items when navigating with arrow keys.

---

#### **Prerequisites**
- Git must be installed on the system.
- The gem should handle exceptions in cases such as:
  - Git command errors.
  - Nonexistent repositories.
  - User lacks access permissions.

---

### Future Expansion
The gem will include additional sub-commands, such as:
- `goops backup`: Save the current state to a temporary branch.
- `goops restore`: Advanced branch or commit restoration.
- `goops log`: Enhanced commit history display with search filters.

---

The `git_oops` gem will optimize commit management and recovery tasks, minimize data loss risks, and enhance the user experience when working with Git.
