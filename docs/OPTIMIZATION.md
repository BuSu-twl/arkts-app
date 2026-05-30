# 代码审查与优化记录

## 已修复（本次）

### 个人中心 `MySetting.ets`
- 组件名统一为 `MySetting`，底部 Tab 跳转 `pages/MySetting`
- 使用 `@State` 绑定昵称/手机/余额，**退出登录后 UI 正确刷新**
- 预设头像改为 `$rawfile('1.png')` 等，修复 `getAvatarRawPath` 路径
- 自定义头像仍走 `filesDir`
- 精简菜单，去掉无实现的占位项；优惠券跳转首页
- 登录校验（编辑资料、已购订单）

### 数据层 `Models.ets`
- 用户增加 `balance`（默认 1000），**余额支付校验与扣款**
- `toPayItem` 图片空数组兜底
- `getPresetAvatarFile` / `isCustomAvatarName` 工具方法

### 编辑页 `edit.ets`
- 未登录自动跳转登录页
- 预设头像改用 `$rawfile('1.png'~'6.png')`，修复动态 `$r(app.media.N)` 编译风险
- 移除未使用的 `util` 导入

### 支付页 `PayPage.ets`
- 无商品参数时提示并返回
- 余额展示、不足禁用与提示
- **仅余额支付**；已移除微信/支付宝及模拟延迟

### 登录与账号（精简）
- 已删除 `SmsLogin.ets`、第三方登录 UI、假短信验证码流程
- 忘记密码：已注册手机号 + 新密码
- 注册：页内图形验证码；`edit` 换绑手机校验占用，无假短信

### 数据加载 `AppInit.ets`
- `productsLoaded` / `usersLoaded` 防止重复加载 mock
- `HomePage` / `RankPage` 统一从 `GlobalStore.allProducts` 读取

---

## 建议后续优化（未改或仅部分）

| 项 | 说明 |
|----|------|
| `notice.ets` / `private.ets` 主题 | 仍含 `#FF5000`，可统一为 `AppTheme` |
| `edit.ets` 主题色 | 部分硬编码色可批量替换 |
| 地址 | `saveAddress` 未持久化 |
| 数据持久化 | 重启丢失会话，可用 Preferences |
| 消息通知 | `notice` 仍为本地静态列表，未接推送 |

---

*与 `PROJECT.md` 配套阅读。*
