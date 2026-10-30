# 精选商城 · HarmonyOS NEXT

> 一个基于 **HarmonyOS NEXT / ArkTS / ArkUI** 的电商类移动应用示例，使用本地 Mock 数据 + 沙箱持久化实现完整购物闭环，无需后端即可运行与演示。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-HarmonyOS%20NEXT-blue.svg)](#)
[![Language](https://img.shields.io/badge/Language-ArkTS-ff4d4f.svg)](#)

---

## 项目简介

「精选商城」是一个课程实践级的电商 App，覆盖了从浏览、推荐、加购、领券、余额支付到个人中心的完整购物流程。项目重点在于：

- **声明式 UI（ArkUI）**：使用 `@State` / `@Prop` 状态驱动界面，路由通过 `main_pages.json` 注册。
- **单例全局状态 + 沙箱持久化**：无后端时，用户资料、购物车、订单、领券、浏览记录写入沙箱 `user_data.json`，重启后保留。
- **规则化推荐**：基于订单 / 收藏 / 购物车 / 浏览行为加权类目打分，提供「兴趣 Top6 分类精选」与「猜你喜欢」。

> 仓库内已包含两份配套文档：`docs/PROJECT.md`（需求分析、流程与代码索引）与 `docs/OPTIMIZATION.md`（代码审查与优化记录），深入阅读建议从这两份文档入手。

---

## 功能特性

| 模块 | 功能点 |
|------|--------|
| 首页 | 热销 Top5 轮播、优惠券领取、兴趣 Top6 分类精选、个性化推荐 |
| 排行榜 | 全站热销榜、左侧品类分类榜 |
| 商品详情 | 店铺头像、加购、收藏双态图标、立即购买、浏览记录 |
| 购物车 | 按用户隔离、已购商品置后灰显、勾选结算 |
| 收藏 | 按用户隔离、猜你喜欢 |
| 优惠券 | 独立领券页，同步已领状态 |
| 账号 | 密码登录、图形验证码注册、忘记密码（已移除短信 / 第三方登录） |
| 支付 | 优惠券满减、**仅余额支付**、订单生成 |
| 订单 | 当前用户订单列表 |
| 个人中心（MySetting） | 头像 / 余额 / 资料编辑、订单 / 购物车 / 收藏、消息通知、隐私协议、退出 |
| 资料编辑 | 昵称 / 密码 / 头像（默认 + 系统推荐 + 自定义）、换绑手机 |
| 消息通知 | 本地静态列表、已读状态沙箱持久化 |

---

## 技术栈

- **平台**：HarmonyOS NEXT
- **语言**：ArkTS
- **UI 框架**：ArkUI（声明式开发范式）
- **构建**：Hvigor
- **数据**：`product.json` + `user.json` 作为种子数据；运行时用户数据落盘至沙箱 `filesDir/user_data.json`、`notice_read.json`
- **主题**：红白主题（`AppTheme` 主色 `#E60012`）

---

## 工程结构

```
arkts-app/
├── AppScope/                      # 应用级配置（图标、字符串等）
├── docs/
│   ├── PROJECT.md                 # 需求分析、流程图与代码索引
│   └── OPTIMIZATION.md            # 代码审查与优化记录
├── entry/src/main/ets/
│   ├── entryability/              # EntryAbility 启动与持久化初始化
│   ├── common/                    # AppInit / AppTheme / AvatarUtils / UserPersistence / NoticePersistence / LoginNav
│   ├── components/                # BottomNavBar 底部三 Tab
│   ├── model/                     # Models.ets：GlobalStore / ProductUtils / RecommendUtils
│   └── pages/                     # 各业务页面（含 MySetting、CouponPage 等）
├── entry/src/mock/                # product.json / user.json 种子数据
├── hvigor/                        # 构建脚本
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

### 路由一览（`main_pages.json`）

```
Login, ForgetPwd, Register
HomePage, RankPage, MySetting
ProductDetail, FavoritePage, CartPage
PayPage, PayResultPage, OrderListPage
CouponPage, edit, notice, private
```

- **Tab 切换**：`router.replaceUrl`（避免返回栈过深）
- **进入子页**：`router.pushUrl`（可 `router.back()` 返回）

---

## 运行方式

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)（HarmonyOS NEXT 版本）。
2. 导入本工程（Open Project → 选择仓库根目录）。
3. 通过 `hvigor` 同步依赖（`oh-package.json5` 中已声明 `@ohos/hypium`、`@ohos/hamock` 等）。
4. 连接真机或启动模拟器，点击 **Run** 启动 `entry` 模块。
5. 首屏为 `HomePage`（游客可浏览）；测试账号见 `docs/PROJECT.md` 附录 B。

> 注：本项目不依赖任何后端服务，所有数据来自本地 Mock 与沙箱持久化。

---

## 文档索引

- 需求树、数据流、业务流程图与逐模块代码索引 → [`docs/PROJECT.md`](./docs/PROJECT.md)
- 已完成的优化项与后续建议 → [`docs/OPTIMIZATION.md`](./docs/OPTIMIZATION.md)

---

## License

本项目以 [MIT License](./LICENSE) 开源。
