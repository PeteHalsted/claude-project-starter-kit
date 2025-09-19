---
description: "Review code changes since last commit using code-reviewer subagent"
allowed-tools: ["Task", "Bash"]
---

I'll use the code-reviewer subagent to review all code changes since the last commit or checkpoint.

Let me first check what files have been modified:

!git status --porcelain

!git diff --name-only HEAD

Now I'll use the Task tool to launch the code-reviewer subagent to perform a comprehensive review of these changes:

I need to use the Task tool with the code-reviewer subagent to analyze the code changes. The code-reviewer subagent will examine:

1. **Code Quality**: Review for best practices, maintainability, and adherence to project standards
2. **Security**: Check for potential security vulnerabilities or risks
3. **Performance**: Identify potential performance issues or improvements
4. **Testing**: Ensure adequate test coverage and quality
5. **Documentation**: Verify code is properly documented
6. **Architecture**: Check for proper separation of concerns and design patterns

The review will focus on the modified files and provide actionable feedback for improvement.