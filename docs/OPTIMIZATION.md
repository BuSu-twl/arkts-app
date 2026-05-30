# 代码审查与优化记录

> 与 `PROJECT.md` 配套阅读。记录已完成的优化项与后续建议。

---

## 已修复 / 已实现

### 应用入口与持久化

| 模块 | 说明 |
|------|------|
| `UserPersistence.ets` | 用户数据读写沙箱 `filesDir/user_data.json`；首次从 `mock/user.json` 种子，编辑资料/注册/领券/下单/退出等时机 `persistUsersToDisk()` |
| `NoticePersistence.ets` | 消息已读 ID 持久化 `filesDir/notice_read.json`；单条/全部已读后再次进入仍保持已读 |
| `EntryAbility.ets` | 启动时 `UserPersistence.init` + `NoticePersistence.init` |
| `AppInit.ets` | 用户数据经 `UserPersistence.loadUsers()` 加载；`productsLoaded` / `usersLoaded` 防重复加载 |

### 个人中心 `MySetting.ets`

- 组件名与路由统一为 `MySetting` / `pages/MySetting`
- `@State` 绑定昵称/手机/余额/头像，退出登录后 UI 正确刷新
- 头像：`AvatarUtils` 默认 `avatars/img.png`；自定义头像走 `filesDir/custom_*.png`
- 菜单精简；**优惠券**跳转独立页 `CouponPage`（不再 Toast 跳首页）
- 收藏菜单图标：`app.media.favorite`

### 头像 `AvatarUtils.ets` + `edit.ets`

- 新用户默认头像存 `img.png`，展示 `avatars/img.png`
- 编辑页系统推荐：`avatars/img/01.jpg` ~ `06.jpg/png`
- 相册自定义头像保存至沙箱

### 首页与推荐

- **分类精选**：`getInterestCategoryFeatured` 取兴趣分 Top **6** 品类，每类展示热度最高一件；无行为时按品类热度回退
- 个性化推荐：`RecommendUtils` 订单/收藏/购物车/浏览加权

### 商品详情 `ProductDetail.ets`

- **店铺头像**：`Product.shopAvatar` → `$rawfile(avatars/img/storeImg/*.png)`
- **收藏双态**：未收藏 `favorite.png`，已收藏 `favorite_active.png` + 「已收藏」文案
- `isProductFavorited` + `onPageShow` 刷新收藏状态

### 消息通知 `notice.ets`

- 静态种子列表 + `NoticePersistence` 合并已读状态
- `markAsRead` / `markAllRead` 写磁盘；`onPageShow` 重新加载

### 优惠券 `CouponPage.ets`

- 独立页面展示可领/已领券，与 `GlobalStore.claimedCouponIds` 同步

### 登录与账号（精简）

- 已删除 `SmsLogin.ets`、第三方登录 UI、假短信验证码
- 忘记密码：已注册手机号 + 新密码
- 注册：页内图形验证码；`edit` 换绑手机校验占用

### 支付 `PayPage.ets`

- **仅余额支付**；已移除微信/支付宝及模拟延迟
- 余额展示、不足拦截与扣款

### 数据层 `Models.ets`

- 用户 `balance`（默认 1000，注册赠 200）
- `Product.shopAvatar` 店铺头像字段
- `toPayItem` / `resolvePayItemImage` 订单图兼容
- `persistUsersToDisk` 统一写回沙箱

### 页面体验

- `CartPage` / `FavoritePage`：`< 返回` + `router.back()`
- 应用图标：`app_start_icon.png` / `background.png` / `foreground.png`

### Mock 数据

- `product.json`：30 条商品均含 `shopAvatar`
- 已删除 `orders.json`（订单仅存用户 `orders` 字段）

---

## 建议后续优化（未改或仅部分）

| 项 | 说明 |
|----|------|
| `notice.ets` / `private.ets` 主题 | 仍含 `#FF5000`，可统一为 `AppTheme` |
| `edit.ets` 主题色 | 部分硬编码色可批量替换 |
| 地址 | `saveAddress` 未持久化 |
| 消息推送 | 仍为本地静态列表，未接系统推送 |
| 收藏取消 | 详情页已收藏仅提示，未提供一键取消 |
| 店铺头像资源 | `storeImg` 目前 2 张图循环分配，可扩充并按店铺名映射 |
| 单元测试 | `parseHotValue`、`RecommendUtils` 打分、`AvatarUtils` 路径解析 |

---

*最后更新：与 master 分支当前代码同步（含用户/通知持久化、CouponPage、头像与收藏、分类精选 Top6、店铺头像）。*
