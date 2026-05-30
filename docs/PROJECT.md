# 精选商城 HarmonyOS 项目文档

> 仓库：`https://gitee.com/bu-su/app.git`  
> 技术栈：HarmonyOS NEXT / ArkTS / ArkUI / 本地 Mock 数据  
> 个人中心页面：**`pages/MySetting`**（`MySetting.ets`）

---

## 一、APP 展示（运行与页面跳转）

### 1.1 启动与入口

| 环节 | 说明 |
|------|------|
| 入口 Ability | `EntryAbility.ets` 初始化 `UserPersistence`、`NoticePersistence`，调用 `initAppData()` 加载商品与用户（用户优先读沙箱 `user_data.json`），再 `loadContent('pages/HomePage')` |
| 首屏 | **首页** `HomePage`（非登录页，游客可浏览） |
| 底部导航 | `BottomNavBar`：首页 / 排行榜 / **个人中心（MySetting）** |

### 1.2 页面路由注册（`main_pages.json`）

```
Login, ForgetPwd, Register
HomePage, RankPage, MySetting
ProductDetail, FavoritePage, CartPage
PayPage, PayResultPage, OrderListPage
CouponPage, edit, notice, private
```

### 1.3 主要跳转关系（运行路径）

```mermaid
flowchart TB
  subgraph entry [启动]
    A[EntryAbility] --> H[HomePage 首页]
  end

  subgraph tabs [底部 Tab replaceUrl]
    H <-->|Tab0| H
    H <-->|Tab1| R[RankPage 排行榜]
    H <-->|Tab2| M[MySetting 个人中心]
    R <-->|Tab2| M
    M <-->|Tab0| H
  end

  subgraph shop [购物流程 pushUrl]
    H --> D[ProductDetail 商品详情]
    R --> D
    D --> P[PayPage 支付]
    D -->|加购| GS[(GlobalStore 购物车)]
    H -->|加购| GS
    GS --> C[CartPage 购物车]
    C --> P
    P -->|未登录| L[Login 登录]
    L -->|LoginNav| P
    P --> PR[PayResultPage 支付结果]
    PR --> O[OrderListPage 订单]
    PR --> H
  end

  subgraph user [账号与个人中心]
    L --> FP[ForgetPwd 忘记密码]
    L --> RG[Register 注册]
    M --> E[edit 修改资料]
    M --> N[notice 消息通知]
    M --> PV[private 隐私协议]
    M --> O
    M --> C
    M --> F[FavoritePage 收藏]
    M --> CP2[CouponPage 优惠券]
  end
```

### 1.4 典型用户操作路径

| 场景 | 路径 |
|------|------|
| 浏览商品 | 首页轮播/推荐 → 商品详情 |
| 领券下单 | 首页领券（需登录）→ 详情「立即购买」或购物车结算 → 支付 → 结果页 |
| 未登录支付 | 支付页 → 登录 → `LoginNav` 自动回到支付页 |
| 看排行 | Tab 排行榜 → 总排行/分类排行（左侧品类）→ 详情 |
| 个人中心 | Tab **MySetting** → 修改资料 / 订单 / 购物车 / 收藏 / 优惠券 / 通知 / 隐私 |

### 1.5 路由 API 约定

- **Tab 切换**：`router.replaceUrl`（避免栈过深）
- **进入子页**：`router.pushUrl`（可 `router.back()` 返回）
- **带参跳转**：商品 `RouteParams { product }`；支付 `PayRouteParams { items, fromCart }`

---

## 二、需求分析

### 2.1 需求树状图

从**业务目标**逐层分解需求：实线为当前已实现功能；`~~删除线~~` 为已从代码移除、不切实际的项。

#### 树状结构（Mermaid）

```mermaid
mindmap
  root((精选商城 APP))
    用户与账号
      密码登录
        账号/手机/会员名
        user.json 本地校验
      账号注册
        页内图形验证码
        写入内存用户
      忘记密码
        已注册手机号验证
        重置密码
      登录态管理
        退出登录
        待支付回流 LoginNav
    商品与浏览
      首页 HomePage
        热销 Top5 轮播
        优惠券领取
        兴趣 Top6 分类精选
      个性化推荐
        订单加权
        收藏/购物车/浏览
      排行榜 RankPage
        全站热销榜
        左侧品类分类榜
      商品详情
        加购
        收藏双态图标
        店铺头像
        立即购买
        浏览记录
    交易与订单
      购物车 CartPage
        按用户隔离
        已购置后灰显
        勾选结算
      优惠券
        满减规则
        领取记录
        CouponPage 独立页
      结算支付 PayPage
        仅余额支付
        余额不足拦截
      订单
        支付成功生成
        订单列表
    个人中心
      MySetting
        头像与余额
        菜单入口
      资料编辑 edit
        昵称/密码/头像
        系统推荐头像
        换绑手机
      消息通知 notice
        本地静态列表
        已读持久化
      隐私协议 private
    非功能需求
      Mock 数据
        product.json
        user.json 种子
      沙箱持久化
        user_data.json
        notice_read.json
      UI 主题
        AppTheme 红白
      运行设备
        phone 手机
```

#### 树状结构（文本）

```
精选商城 APP
│
├─ 用户与账号 ─────────────────────────────────────────
│  ├─ 密码登录 ............... Login · loginByPassword
│  ├─ 账号注册 ............... Register · 图形验证码 · registerUser
│  ├─ 忘记密码 ............... ForgetPwd · resetPassword
│  └─ 登录态管理 ............. logout · pendingPay · LoginNav
│
├─ 商品与浏览 ─────────────────────────────────────────
│  ├─ 首页 ................... HomePage · 轮播/领券/兴趣 Top6 分类精选
│  ├─ 个性化推荐 ............. RecommendUtils · 行为加权
│  ├─ 排行榜 ................. RankPage · 全站榜/品类榜
│  └─ 商品详情 ............... ProductDetail · 加购/收藏双态/店铺头像/购买
│
├─ 交易与订单 ─────────────────────────────────────────
│  ├─ 购物车 ................. CartPage · 多用户隔离/已购置后
│  ├─ 优惠券 ................. CouponPage · GlobalStore.claimCoupon
│  ├─ 结算支付 ............... PayPage · 仅余额 · createOrder
│  └─ 订单 ................... PayResultPage · OrderListPage
│
├─ 个人中心 ───────────────────────────────────────────
│  ├─ MySetting .............. 头像/余额/菜单/退出
│  ├─ edit ................... 昵称/密码/头像/换绑手机 · AvatarUtils
│  ├─ notice ................. 静态消息 · NoticePersistence 已读
│  └─ private ................ 隐私协议
│
└─ 非功能需求 ─────────────────────────────────────────
   ├─ Mock 数据 ............... product.json + user.json（种子）
   ├─ 沙箱持久化 ............. user_data.json · notice_read.json
   ├─ UI 主题 ................. AppTheme #E60012
   └─ 设备 .................... HarmonyOS phone
```

#### 已移除需求（不在实现范围）

```
~~短信验证码登录~~  ~~微信/抖音/Twitter 登录~~  ~~微信/支付宝模拟支付~~
```

**图例**

| 符号 | 含义 |
|------|------|
| 树节点 | 可验收的功能需求 |
| 叶子 `·` 后缀 | 对应页面或核心方法 |
| 删除线项 | 无真实 SDK/后端，已从代码删除 |

### 2.2 功能需求汇总

| 模块 | 功能点 | 优先级 | 实现说明 |
|------|--------|--------|----------|
| 首页 | 热销 Top5 轮播、优惠券领取、兴趣 Top6 分类精选、规则个性化推荐 | P0 | `HomePage` + `RecommendUtils` |
| 排行榜 | 全站热销排序；分类排行 + 左侧品类栏 | P0 | `RankPage` |
| 商品 | 详情展示、店铺头像、加购、收藏双态（登录）、立即购买 | P0 | `ProductDetail` |
| 购物车 | 按用户隔离；已购商品置后灰显；勾选结算；返回键 | P0 | `CartPage` |
| 收藏 | 按用户隔离；猜你喜欢；返回键 | P1 | `FavoritePage` |
| 优惠券 | 独立领券页，同步已领状态 | P1 | `CouponPage` |
| 账号 | 密码登录、注册（图形验证码）、忘记密码 | P0 | 无短信/第三方登录 |
| 支付 | 优惠券满减、**余额支付**、订单生成 | P0 | 已移除微信/支付宝选项 |
| 订单 | 当前用户订单列表 | P0 | `OrderListPage` |
| 个人中心 | **MySetting**：头像/余额/资料、订单/购物车/收藏、消息通知、隐私协议、退出 | P0 | `MySetting.ets` |
| 账户余额 | 余额支付校验与扣款（默认 1000 元 mock，注册赠 200） | P1 | `User.balance` |
| 资料编辑 | 昵称/密码/头像（默认+系统推荐+自定义）；换绑手机 | P1 | `edit.ets` + `AvatarUtils` |
| 消息通知 | 本地静态列表；已读状态沙箱持久化 | P1 | `notice.ets` + `NoticePersistence` |

### 2.3 非功能需求

- 数据：**Mock JSON 作种子** + **沙箱持久化**（`user_data.json`、`notice_read.json`）；商品数据仍来自 `product.json`
- UI：**红白主题** `AppTheme` 统一主色 `#E60012`
- 设备：手机 `phone`

### 2.4 数据流图

```mermaid
flowchart LR
  subgraph sources [数据源]
    PJ[product.json]
    UJ[user.json 种子]
    RF[rawfile 商品图/头像/店铺图]
  end

  subgraph init [启动加载]
    EA[EntryAbility init]
    UP[UserPersistence.loadUsers]
    AI[AppInit.initAppData]
    PJ --> AI
    UJ --> UP
    UP --> AI
    AI --> GS[GlobalStore.allProducts / allUsers]
  end

  subgraph session [登录会话]
    GS --> CU[currentUser]
    CU --> CL[cartList / favoriteList / orderList]
    CU --> BH[browseHistory]
    CU --> CC[claimedCouponIds]
  end

  subgraph ui [页面读写]
    H[HomePage] --> GS
    D[ProductDetail] -->|recordBrowse| BH
    D --> GS
    C[CartPage] -->|syncCart| CU
    P[PayPage] -->|createOrder| CU
    M[MySetting] --> CU
    E[edit] -->|改资料| CU
    N[notice] --> NP[NoticePersistence]
  end

  subgraph persist [沙箱持久化]
    CU -->|persistUsersToDisk| UD[(user_data.json)]
    NP --> NR[(notice_read.json)]
  end
```

### 2.5 核心实体关系

| 实体 | 存储位置 | 说明 |
|------|----------|------|
| `Product` | `product.json` → `allProducts` | 含 `category`、`shopAvatar`（rawfile 店铺头像路径） |
| `User` | 沙箱 `user_data.json`（种子 `user.json`） | 含 `cartItems[]`、`favoriteIds[]`、`orders[]`、`avatar`、`balance` |
| `Order` | 用户 `orders` + 运行时 `orderList` | 支付成功后追加 |
| `Coupon` | `GlobalStore.COUPONS` 常量 | 领取记录在用户 `claimedCouponIds` |
| 消息已读 | 沙箱 `notice_read.json` | 已读消息 ID 列表 |

### 2.6 业务流程图

以下流程图按**实际代码逻辑**绘制，菱形为判断分支，矩形为页面或操作。

#### 2.6.1 应用启动流程

```mermaid
flowchart TD
  START([用户打开 APP]) --> EA[EntryAbility.onWindowStageCreate]
  EA --> PINIT[UserPersistence + NoticePersistence init]
  PINIT --> INIT[initAppData 加载数据]
  INIT --> LOAD_P[product.json → allProducts]
  INIT --> LOAD_U[UserPersistence.loadUsers → allUsers]
  LOAD_P --> HOME[loadContent HomePage]
  LOAD_U --> HOME
  HOME --> GUEST{是否已登录?}
  GUEST -->|否| BROWSE[游客浏览商品/排行榜]
  GUEST -->|是| SESSION[currentUser 会话已挂载]
  BROWSE --> TAB[BottomNavBar 三 Tab 切换]
  SESSION --> TAB
```

#### 2.6.2 登录 / 注册 / 找回密码流程

```mermaid
flowchart TD
  ENTRY([进入 Login 页]) --> INPUT[输入账号 + 密码]
  INPUT --> LOGIN{loginByPassword}
  LOGIN -->|成功| NAV[navigateAfterLogin]
  LOGIN -->|失败| TOAST1[提示账号或密码错误]

  ENTRY --> REG_LINK[点击注册账号]
  REG_LINK --> REG[Register 页]
  REG --> CAPTCHA[对照页内图形验证码]
  CAPTCHA --> REG_OK{registerUser}
  REG_OK -->|成功| NAV
  REG_OK -->|失败| TOAST2[手机号已注册等提示]

  ENTRY --> FP_LINK[点击忘记密码]
  FP_LINK --> FP[ForgetPwd 页]
  FP --> FP_INPUT[已注册手机号 + 新密码]
  FP_INPUT --> FP_OK{resetPassword}
  FP_OK -->|成功| BACK[返回 Login]
  FP_OK -->|失败| TOAST3[手机号未注册]

  NAV --> PENDING{存在 pendingPay?}
  PENDING -->|是| PAY[replaceUrl → PayPage 继续支付]
  PENDING -->|否| HOME[replaceUrl → HomePage]
```

#### 2.6.3 购物流程（浏览 → 加购 → 结算）

```mermaid
flowchart TD
  H([HomePage / RankPage]) --> D[ProductDetail 商品详情]
  D --> BROWSE[recordBrowse 记录浏览]
  BROWSE --> ACT{用户操作}

  ACT -->|加购| CART_ADD[GlobalStore.addToCart]
  CART_ADD --> SYNC1[syncCartToCurrentUser]
  SYNC1 --> D

  ACT -->|收藏| FAV_CHK{已登录?}
  FAV_CHK -->|否| LOGIN[跳转 Login]
  FAV_CHK -->|是| FAV[addToFavorite]
  FAV --> D

  ACT -->|立即购买| BUY[组装 PayRouteParams]
  H -->|首页领券| COUPON{已登录?}
  COUPON -->|否| LOGIN
  COUPON -->|是| CLAIM[claimCoupon]

  BUY --> PAY_PAGE[PayPage]
  CART_PAGE[CartPage 勾选商品] --> PAY_PAGE
  LOGIN --> LOGIN_NAV[LoginNav 回流]
  LOGIN_NAV --> PAY_PAGE
```

#### 2.6.4 余额支付流程

```mermaid
flowchart TD
  PAY([PayPage 确认支付]) --> AUTH{已登录?}
  AUTH -->|否| SAVE[setPendingPay 暂存订单]
  SAVE --> LOGIN[pushUrl Login]
  LOGIN --> LOGIN_OK[登录成功 LoginNav]
  LOGIN_OK --> PAY

  AUTH -->|是| RECalc[recalcAmount 计算金额]
  RECalc --> COUPON[筛选可用券 / 选最优券]
  COUPON --> BAL_CHK{余额 ≥ 应付?}
  BAL_CHK -->|否| FAIL1[提示余额不足]
  BAL_CHK -->|是| ORDER[createOrder balance]
  ORDER --> DEDUCT[扣减 User.balance]
  DEDUCT --> SYNC[syncOrdersToCurrentUser]
  SYNC --> FROM{来自购物车?}
  FROM -->|是| REMOVE[removeCartItemsForPayItems]
  FROM -->|否| RESULT
  REMOVE --> RESULT[PayResultPage 支付成功]
  RESULT --> NEXT{用户选择}
  NEXT --> ORDERS[OrderListPage 查看订单]
  NEXT --> HOME[返回 HomePage]
```

#### 2.6.5 用户会话与数据同步流程

```mermaid
flowchart TD
  LOGIN_OK([loginByPassword / registerUser 成功]) --> APPLY[applyUserSession]
  APPLY --> LOAD_O[loadUserOrders → orderList]
  APPLY --> LOAD_C[loadUserCart → cartList]
  APPLY --> LOAD_F[loadUserFavorites → favoriteList]
  APPLY --> LOAD_B[loadUserBrowseHistory]
  APPLY --> LOAD_CP[加载 claimedCouponIds]

  USE[页面操作 加购/收藏/领券/支付/改资料] --> SYNC{写回用户数据}
  SYNC --> SYNC_C[syncCartToCurrentUser]
  SYNC --> SYNC_F[syncFavoritesToCurrentUser]
  SYNC --> SYNC_O[syncOrdersToCurrentUser]
  SYNC --> SYNC_B[syncBrowseToCurrentUser]
  SYNC --> DISK[persistUsersToDisk → user_data.json]

  LOGOUT([MySetting 退出登录]) --> PERSIST[persistSession 写回 allUsers + 磁盘]
  PERSIST --> CLEAR[清空 currentUser 与运行时列表]
  CLEAR --> IDLE[回到未登录态]
```

#### 2.6.6 页面导航总览（简化）

```mermaid
flowchart LR
  EA[EntryAbility] --> HP[HomePage]
  HP <-->|Tab| RP[RankPage]
  HP <-->|Tab| MS[MySetting]

  HP --> PD[ProductDetail]
  RP --> PD
  PD --> PP[PayPage]
  HP --> CP[CartPage]
  CP --> PP
  PP --> PR[PayResultPage]
  MS --> ED[edit]
  MS --> OL[OrderListPage]
  MS --> LG[Login]
  LG --> RG[Register]
  LG --> FP[ForgetPwd]
```

**流程图说明**

| 编号 | 流程 | 关键文件 |
|------|------|----------|
| 2.6.1 | 冷启动加载 mock，首屏 HomePage | `EntryAbility.ets` · `AppInit.ets` |
| 2.6.2 | 密码登录、图形验证码注册、找回密码 | `Login.ets` · `Register.ets` · `LoginNav.ets` |
| 2.6.3 | 详情页加购/收藏/购买，领券需登录 | `ProductDetail.ets` · `HomePage.ets` |
| 2.6.4 | 仅余额支付，未登录中断可回流 | `PayPage.ets` · `Models.createOrder` |
| 2.6.5 | 登录挂载用户数据，退出写回内存 | `Models.applyUserSession` · `logout` |
| 2.6.6 | Tab 与子页 push/replace 关系一览 | `BottomNavBar.ets` · `main_pages.json` |

---

## 三、技术分析（功能实现与代码解析）

### 3.1 工程结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 启动：持久化 init + initAppData + HomePage
├── common/
│   ├── AppInit.ets                  # 加载 mock 商品与用户（UserPersistence）
│   ├── AppTheme.ets                 # 红白主题色常量
│   ├── AvatarUtils.ets              # 默认/系统推荐头像路径
│   ├── UserPersistence.ets          # 沙箱 user_data.json
│   ├── NoticePersistence.ets        # 沙箱 notice_read.json
│   └── LoginNav.ets                 # 登录后回支付/首页
├── components/BottomNavBar.ets      # 三 Tab → MySetting
├── model/Models.ets                 # 实体、GlobalStore、ProductUtils、RecommendUtils
└── pages/                           # 各业务页面（含 CouponPage）
entry/src/mock/
├── product.json                     # 含 shopAvatar
└── user.json                        # 种子用户（avatar: img.png）
entry/src/main/resources/
├── base/profile/main_pages.json     # 路由表
├── base/media/                      # favorite / favorite_active 等 UI 图标
└── rawfile/
    ├── 1.png …                      # 商品图
    └── avatars/
        ├── img.png                  # 默认用户头像
        └── img/
            ├── 01.jpg … 06.jpg/png  # 编辑页系统推荐头像
            └── storeImg/            # 店铺头像 1.png、2.png …
```

### 3.2 数据初始化与用户会话

**代码位置**：`AppInit.ets`、`UserPersistence.ets`、`GlobalStore.initUsers` / `applyUserSession`

```typescript
// EntryAbility — 沙箱持久化初始化
UserPersistence.init(this.context);
NoticePersistence.init(this.context);
initAppData();

// AppInit — 商品读 mock；用户读沙箱（首次从 user.json 种子）
GlobalStore.allProducts = productData.data;
GlobalStore.initUsers(UserPersistence.loadUsers() as User[]);

// 关键写盘时机
GlobalStore.persistUsersToDisk();  // 编辑资料、注册、领券、下单、退出等
```

**解析**：无后端时，商品仍用静态 JSON；**用户资料与会话数据**写入沙箱 `filesDir/user_data.json`，重启后保留购物车、订单、领券、头像等修改。切换用户前通过 `persistSession*` 写回 `allUsers` 并落盘。

### 3.3 首页：轮播、领券、分类精选、个性化推荐

| 功能 | 实现 | 文件 |
|------|------|------|
| 热销轮播 | `ProductUtils.getTopHotProducts` 解析 `hot` 字段（支持「万」） | `HomePage.ets` |
| 分类精选 | 兴趣分 Top **6** 品类，每类取热度最高一件；无行为时按品类热度回退 | `RecommendUtils.getInterestCategoryFeatured` |
| 领券 | `GlobalStore.claimCoupon` + 登录校验；个人中心进 `CouponPage` | `HomePage.ets` · `CouponPage.ets` |
| 为你推荐 | 订单/收藏/购物车/浏览加权类目打分 | `RecommendUtils.getPersonalizedRecommend` |

**分类精选规则**：

```typescript
// 类目权重：订单 +5、收藏 +3、购物车 +2、浏览 +1
// 取权重最高的 6 个 category，每类展示 parseHot 最高的一件商品
GlobalStore.getCategoryFeaturedRecommend(6);
```

**推荐规则（节选）**：

```typescript
// 类目权重：订单 +5、收藏 +3、购物车 +2、浏览 +1
// 商品得分：偏好类目加分 + 已收藏/在购加分 + 热度兜底；已购排除
RecommendUtils.getPersonalizedRecommend(allProducts, user, browseIds, purchasedIds, count);
```

**解析**：冷启动（未登录或无行为）回退为全站热销；登录后 `onPageShow` 刷新推荐列表。

### 3.4 排行榜：总榜与分类榜

**代码位置**：`RankPage.ets`、`ProductUtils.sortByHotDesc` / `getProductsByCategory`

- `rankMode === 0`：全商品按热度排序列表  
- `rankMode === 1`：**左侧纵向品类** + 右侧该分类商品排行  

**解析**：分类模式用 `Row` 固定宽度侧栏 + `List` 主列表，选中项左侧红色竖条高亮（`AppTheme.PRIMARY`）。

### 3.5 购物车：多用户与已购置后

**代码位置**：`CartPage.ets`、`GlobalStore.getSortedCartList` / `isProductPurchased`

- 加购：`GlobalStore.addToCart` → `syncCartToCurrentUser` 写 `cartItems: { productId, count }`  
- 游客购物车：登录时 `mergeCartItemsIntoList` 合并  
- 已购商品：`getSortedCartList` 将 `isProductPurchased` 的条目排到末尾并灰显  

### 3.6 登录注册与支付回流

| 功能 | 关键方法 | 说明 |
|------|----------|------|
| 密码登录 | `loginByPassword` | 账号/手机/会员名 + 密码匹配 |
| 注册 | `registerUser` | 图形验证码通过后写入 `allUsers`，自动登录 |
| 忘记密码 | `resetPassword` | 校验已注册手机号后重置密码 |
| 换绑手机 | `updateUserPhone` | 校验新号未被占用 |
| 待支付 | `setPendingPay` / `consumePendingPay` | 未登录点支付先记参数 |
| 登录后跳转 | `navigateAfterLogin` | 有 pending 则 `replaceUrl` 到 `PayPage` |

> **已移除**：短信验证码登录（`SmsLogin`）、微信/抖音/Twitter 第三方登录入口。

```typescript
// LoginNav.ets
let pending = GlobalStore.consumePendingPay();
if (pending !== null) {
  router.replaceUrl({ url: 'pages/PayPage', params: pending });
} else {
  router.replaceUrl({ url: 'pages/HomePage' });
}
```

### 3.7 支付与订单

**代码位置**：`PayPage.ets`、`GlobalStore.createOrder`

1. `recalcAmount`：商品小计 → 可用券 → 最优券/手选 → `payAmount`  
2. `createOrder`：校验余额 → 生成 `Order`（`status: paid`，`payMethod: balance`）→ 扣款并 `syncOrdersToCurrentUser`  
3. 购物车来源支付：`removeCartItemsForPayItems`  
4. **仅支持余额支付**；已移除微信/支付宝 UI 与模拟延迟

### 3.8 个人中心 MySetting

**代码位置**：`MySetting.ets`（组件名 `MySetting`，路由 **`pages/MySetting`**）

| 菜单项 | 跳转 |
|--------|------|
| 消息通知 | `pages/notice`（静态列表 + 已读持久化） |
| 修改个人信息 | `pages/edit` |
| 已购商品 | `pages/OrderListPage` |
| 购物车 / 收藏 | `CartPage` / `FavoritePage` |
| 优惠券 | `pages/CouponPage` |
| 隐私协议 | `pages/private` |
| 退出登录 | `GlobalStore.logout()` → `persistUsersToDisk` |

**头像逻辑**（`AvatarUtils` + `MySetting.updateAvatar`）：

| 类型 | 存储值 | 展示 |
|------|--------|------|
| 默认 | `img.png` | `$rawfile('avatars/img.png')` |
| 系统推荐 | `avatars/img/0x.jpg\|png` | 对应 rawfile |
| 自定义 | `custom_*.png` | `file://filesDir/...` |

### 3.9 商品详情、店铺头像与收藏

**代码位置**：`ProductDetail.ets`

- `aboutToAppear` / `onPageShow`：`recordBrowse`；`isProductFavorited` 刷新收藏态  
- **店铺区**：`ProductUtils.getShopAvatarRawPath(item)` → `$rawfile(shopAvatar)`，缺省 `avatars/img/storeImg/1.png`  
- **收藏按钮**：未收藏 `app.media.favorite`；已收藏 `app.media.favorite_active` + 「已收藏」  
- 加购 / 立即购买：`addToCart`、跳转 `PayPage`

### 3.10 主题与资源

- **`AppTheme.ets`**：主色、背景、文字、边框常量  
- **商品图**：`$rawfile('1.png')` 等，位于 `resources/rawfile/`  
- **用户头像**：见 §3.8 表  
- **店铺头像**：`product.json` 字段 `shopAvatar`，如 `avatars/img/storeImg/1.png`  
- **收藏图标**：`base/media/favorite.png`、`favorite_active.png`  
- **应用图标**：`app_start_icon.png`、`background.png`、`foreground.png`

---

## 四、项目感悟（技术栈与收获）

### 4.1 HarmonyOS / ArkTS 开发体会

1. **声明式 UI（ArkUI）**  
   状态驱动界面（`@State`、`@Prop`）与 `@Builder` 复用列表行，使首页、个人中心列表等结构清晰；需注意 `onPageShow` 中刷新登录态与推荐数据。

2. **路由与页面配置**  
   所有页面必须在 `main_pages.json` 注册；**路径与文件名一致**（个人中心为 `pages/MySetting` 对应 `MySetting.ets`）。Tab 用 `replaceUrl`，子页用 `pushUrl`，避免返回栈混乱。

3. **单例式 GlobalStore + 沙箱持久化**  
   演示项目用静态类管理会话，用户数据通过 `UserPersistence` 落盘；需在改资料、下单等节点统一 `persistUsersToDisk()`。

### 4.2 业务实现收获

| 主题 | 收获 |
|------|------|
| Mock 驱动 | `product.json` 商品全量；`user.json` 作用户种子 |
| 沙箱持久化 | 无后端也能保留用户修改（资料、订单、领券、浏览合并） |
| 多用户隔离 | 购物车、收藏存 id，展示从 `allProducts` 还原 |
| 规则推荐 | 加权类目 + Top6 分类精选，便于答辩讲解 |
| 头像与收藏 UX | 默认/推荐/自定义头像分层；收藏双态图标反馈 |
| 支付流程 | `pendingPay` + `LoginNav` 解决中断式登录 |

### 4.3 可改进方向

- `notice.ets` / `private.ets` / `edit.ets` 硬编码色统一为 `AppTheme`  
- 详情页已收藏支持一键取消  
- 消息通知对接真实推送或订单状态变更触发  
- 扩充 `storeImg` 并按店铺名精确映射  
- 单元测试覆盖 `parseHotValue`、`RecommendUtils`、`AvatarUtils`  
- 远程 API 替换 Mock，保留 `GlobalStore` 接口层便于迁移  

### 4.4 协作与工程习惯

- 远程仓库 Gitee 协作时注意 **pull 前 stash 本地修改**，避免未跟踪文件（如 `AppTheme.ets`）阻塞合并  
- 个人中心统一为 **MySetting**，勿再保留已删除的 `ProfilePage.ets` 路由，防止编译或跳转失败  

---

## 附录 A：各功能关键代码索引

> 路径均相对于 `entry/src/main/ets/`；行号为当前仓库版本，改代码后可能略有偏移。  
> 数据层统一入口：`model/Models.ets`（`GlobalStore` / `ProductUtils` / `RecommendUtils`）。

### A.1 基础设施

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 应用启动 | `entryability/EntryAbility.ets` | `UserPersistence.init` · `NoticePersistence.init` · `initAppData()` · `loadContent('pages/HomePage')` |
| Mock 商品加载 | `common/AppInit.ets` | `initAppData` · `ensureAppData` |
| 用户沙箱持久化 | `common/UserPersistence.ets` | `loadUsers` · `saveUsers` · `filesDir/user_data.json` |
| 消息已读持久化 | `common/NoticePersistence.ets` | `loadReadIds` · `markRead` · `markAllRead` |
| 头像路径工具 | `common/AvatarUtils.ets` | `DEFAULT_AVATAR_*` · `SYSTEM_PRESET_RAW_PATHS` · `resolveRawfilePath` |
| 页面路由注册 | `resources/base/profile/main_pages.json` | 含 `CouponPage` |
| Mock 数据 | `mock/product.json`、`mock/user.json` | `shopAvatar` · `avatar: img.png` |
| 主题色 | `common/AppTheme.ets` | `AppTheme.PRIMARY` 等 |
| 底部三 Tab | `components/BottomNavBar.ets` | `replaceUrl` → Home / Rank / MySetting |
| 登录后跳转 | `common/LoginNav.ets` | `navigateAfterLogin`（含待支付回流） |

### A.2 用户与账号

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 密码登录 UI | `pages/Login.ets` | `doLogin` |
| 密码登录逻辑 | `model/Models.ets` | `loginByPassword` |
| 注册 + 图形验证码 | `pages/Register.ets` | `doRegister` |
| 注册写用户 | `model/Models.ets` | `registerUser`（默认头像 `img.png`） |
| 忘记密码 | `pages/ForgetPwd.ets` · `Models.ets` | `resetPassword` |
| 登录挂载会话 | `model/Models.ets` | `applyUserSession` · `mergeBrowseIds` |
| 写盘 | `model/Models.ets` | `persistUsersToDisk` → `UserPersistence.saveUsers` |
| 退出登录 | `pages/MySetting.ets` | `doLogout` → `GlobalStore.logout` |
| 待支付暂存 | `model/Models.ets` | `setPendingPay` / `consumePendingPay` |

### A.3 首页与推荐

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 首页刷新 | `pages/HomePage.ets` | `aboutToAppear` / `onPageShow` |
| 热销轮播 | `pages/HomePage.ets` | `getTopHotProducts(products, 5)` |
| 分类精选 Top6 | `pages/HomePage.ets` | `refreshCategoryRecommends` → `getCategoryFeaturedRecommend(6)` |
| 分类精选算法 | `model/Models.ets` | `RecommendUtils.getInterestCategoryFeatured` |
| 领券 | `pages/HomePage.ets` | `claimCoupon` |
| 优惠券页 | `pages/CouponPage.ets` | 列表展示 · `claimCoupon` · 同步 `claimedIds` |
| 个性化推荐 | `pages/HomePage.ets` | `refreshPersonalRecommends` → `getPersonalizedRecommend(6)` |
| 推荐算法 | `model/Models.ets` | `buildCategoryWeights` · `getPersonalizedRecommend` |

### A.4 排行榜

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 全站/分类榜 | `pages/RankPage.ets` | `refreshRankList` · `switchMode` |
| 按品类筛选 | `model/Models.ets` | `getProductsByCategory` · `sortByHotDesc` |

### A.5 商品详情

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 浏览埋点 | `pages/ProductDetail.ets` | `recordBrowse` |
| 店铺头像 | `pages/ProductDetail.ets` | `ProductUtils.getShopAvatarRawPath` |
| 收藏双态 | `pages/ProductDetail.ets` | `isFavorited` · `favorite` / `favorite_active` |
| 是否已收藏 | `model/Models.ets` | `isProductFavorited` · `addToFavorite` |
| 加购 / 购买 | `pages/ProductDetail.ets` | `addToCart` · `toPayItem` → `PayPage` |

### A.6 购物车

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 列表与返回 | `pages/CartPage.ets` | `refresh` · `goBack` |
| 已购置后排序 | `model/Models.ets` | `getSortedCartList` · `isProductPurchased` |
| 结算 | `pages/CartPage.ets` | `goCheckout` |

### A.7 收藏

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 收藏列表 | `pages/FavoritePage.ets` | `refresh` · 删除 · 返回键 |
| 加入收藏 | `model/Models.ets` | `addToFavorite` · `removeFromFavoriteByIndex` |

### A.8 支付与订单

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 支付页（仅余额） | `pages/PayPage.ets` | `recalcAmount` · `doPay` |
| 创建订单 | `model/Models.ets` | `createOrder`（`payMethod: balance`） |
| 订单列表 | `pages/OrderListPage.ets` | `refreshOrders` |
| 订单商品图 | `model/Models.ets` | `resolvePayItemImage` |

### A.9 个人中心与资料

| 功能 | 关键文件 | 关键代码 / 方法 |
|------|----------|-----------------|
| 个人中心 | `pages/MySetting.ets` | `refreshProfile` · `updateAvatar` · 菜单跳转 |
| 头像展示 | `model/Models.ets` | `getAvatarRawPath` → `AvatarUtils` |
| 编辑资料 | `pages/edit.ets` | 系统推荐头像 · `selectCustomAvatar` · `saveProfile` |
| 消息通知 | `pages/notice.ets` | `reloadNotices` · `markAsRead` · `NoticePersistence` |
| 隐私协议 | `pages/private.ets` | 静态展示 |

### A.10 快速定位：Models.ets 核心方法

| 方法 | 用途 |
|------|------|
| `ProductUtils.getTopHotProducts` | 热销榜 |
| `ProductUtils.getShopAvatarRawPath` | 店铺头像 rawfile 路径 |
| `RecommendUtils.getInterestCategoryFeatured` | 兴趣 Top6 分类精选 |
| `RecommendUtils.getPersonalizedRecommend` | 猜你喜欢打分 |
| `GlobalStore.getCategoryFeaturedRecommend` | 首页分类精选门面 |
| `GlobalStore.persistUsersToDisk` | 用户数据写沙箱 |
| `GlobalStore.applyUserSession` | 登录会话挂载 |
| `GlobalStore.createOrder` | 余额下单扣款 |
| `GlobalStore.isProductFavorited` | 详情页收藏态 |

---

## 附录 B：测试账号（示例）

以 `user.json` 为准，例如：

| 手机号 | 密码 | 说明 |
|--------|------|------|
| 13800138000 | 123456 | 张三，含购物车/收藏/订单样例 |
| 13900139000 | abc123 | 李四 |

注册时使用页面内**图形验证码**（6 位数字对照输入）；忘记密码仅需已注册手机号 + 新密码。

---

*文档版本：与当前 `entry` 模块代码同步（2026-05）；个人中心路由 `pages/MySetting`；含沙箱持久化、CouponPage、AvatarUtils、兴趣 Top6 分类精选、店铺头像与收藏双态图标；附录 A 为功能与代码对照索引。*
