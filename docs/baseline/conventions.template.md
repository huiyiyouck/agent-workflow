# 代码与协作规范

> 本文件可按项目复制为 `conventions.md` 后再补充项目技术规范。

## Commit Message

协作信号使用：

```text
[PM] vX.Y PRD 待Review
[UI] vX.Y UI 方案 待Review
[Architect] Reviewed vX.Y PRD R1
[Developer] vX.Y 实现 R2 待Review
[Tester] vX.Y 测试报告 阻塞
[DevOps] vX.Y 部署检查通过
[RoleCreator] 新增 Tester 角色提案
```

常规代码提交可以使用项目自己的规范，如 Conventional Commits。

## 禁止事项

- 禁止 force push。
- 禁止跳过 Git hooks。
- 禁止覆盖未归属修改。
- 禁止 Review 方直接改产出方正文。
- 禁止未经人类确认修改 `baseline/`。
- 禁止把真实密钥写入文档。

## Review 严重程度

| 等级 | 含义 |
|------|------|
| 高 | 阻断阶段定稿，必须修 |
| 中 | 建议本轮修，若延期需记录原因 |
| 低 | 不阻断，可作为后续优化 |
