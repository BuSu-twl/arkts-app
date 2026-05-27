// path: entry/src/main/ets/pages/CartPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Product, PayItem, GlobalStore, RouteParams, PayRouteParams } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct CartPage {
  // 核心数据源
  @State cartList: Product[] = [];
  @State total: number = 0;
  @State recommends: Product[] = [];

  // 存储选中的商品ID
  @State selectedItems: Set<number> = new Set();
  @State isAllSelected: boolean = false;

  aboutToAppear() {
    ensureAppData();
    this.refresh();
    this.recommends = GlobalStore.getPersonalizedRecommend(6);
  }

  onPageShow() {
    this.refresh();
  }

  isPurchased(item: Product): boolean {
    return GlobalStore.isProductPurchased(item.id);
  }

  // 1. 获取并清洗数据，确保拿到的每一个 product 都是能在本页面独立响应的物理实体
  refresh() {
    if (GlobalStore.isLoggedIn()) {
      GlobalStore.syncCartToCurrentUser();
    }

    // 从全局拿到原始购物车列表
    const rawList = GlobalStore.getSortedCartList() || [];

    this.cartList = rawList.map(item => {
      return {
        id: item.id,
        name: item.name,
        price: item.price,
        description: item.description,
        images: item.images,
        shopname: item.shopname,
        hot: item.hot,
        count: item.count ?? 1,
        category: item.category
      } as Product;
    });

    // 清理无效的选中 ID
    const validIds = new Set(this.cartList.map(item => item.id));
    const newSelected = new Set<number>();
    this.selectedItems.forEach(id => {
      if (validIds.has(id)) {
        newSelected.add(id);
      }
    });
    this.selectedItems = newSelected;

    this.calcTotal();
    this.updateAllSelectedStatus();
  }

  // 2. 重新计算总价
  calcTotal() {
    let sum = 0;
    this.cartList.forEach(item => {
      if (this.selectedItems.has(item.id)) {
        sum += item.price * (item.count ?? 1);
      }
    });
    this.total = sum;
  }

  // 单选
  toggleSelect(item: Product) {
    if (this.selectedItems.has(item.id)) {
      this.selectedItems.delete(item.id);
    } else {
      this.selectedItems.add(item.id);
    }
    this.selectedItems = new Set(this.selectedItems); // 强行触发局部响应
    this.calcTotal();
    this.updateAllSelectedStatus();
  }

  // 全选
  toggleSelectAll() {
    if (this.isAllSelected) {
      this.selectedItems.clear();
    } else {
      this.cartList.forEach(item => {
        this.selectedItems.add(item.id);
      });
    }
    this.selectedItems = new Set(this.selectedItems);
    this.calcTotal();
    this.updateAllSelectedStatus();
  }

  updateAllSelectedStatus() {
    if (this.cartList.length === 0) {
      this.isAllSelected = false;
      return;
    }
    this.isAllSelected = this.cartList.every(item => this.selectedItems.has(item.id));
  }

  goCheckout() {
    let payItems: PayItem[] = [];
    for (let i = 0; i < this.cartList.length; i++) {
      if (this.selectedItems.has(this.cartList[i].id)) {
        payItems.push(GlobalStore.toPayItem(this.cartList[i]));
      }
    }
    if (payItems.length === 0) return;
    router.pushUrl({
      url: 'pages/PayPage',
      params: { items: payItems, fromCart: true } as PayRouteParams
    });
  }

  build() {
    Column() {
      // 1. 顶部栏（点击首页可以跳转）
      Row() {
        Text("首页").fontSize(16).fontColor(AppTheme.PRIMARY).fontWeight(FontWeight.Bold)
          .onClick(() => router.replaceUrl({ url: 'pages/HomePage' }))
        Text("购物车").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(15)
      .backgroundColor(AppTheme.WHITE)

      // 2. 主滚动区
      List({ space: 10 }) {
        ListItem() {
          if (this.cartList.length === 0) {
            Column() {
              Text("购物车是空的").margin(20).fontColor(AppTheme.TEXT_HINT)
              Button("去挑选宝贝").backgroundColor(AppTheme.PRIMARY)
                .onClick(() => router.replaceUrl({ url: 'pages/HomePage' }))
            }
            .width('100%')
            .padding(30)
          } else {
            Column() {
              // 全选条
              Row() {
                Row() {
                  Image(this.isAllSelected ? $r('app.media.Select') : $r('app.media.unselect'))
                    .width(20).height(20).margin({ right: 8 })
                  Text(this.isAllSelected ? "取消全选" : "全选").fontSize(14).fontColor(AppTheme.TEXT_PRIMARY)
                }
                .onClick(() => this.toggleSelectAll())
                .padding({ left: 12 })

                Blank()
                Text("已选商品直接结算").fontSize(12).fontColor(AppTheme.TEXT_HINT).padding({ right: 12 })
              }
              .width('100%').padding({ top: 8, bottom: 8 }).backgroundColor(AppTheme.BG_MUTED)

              // 核心重点：强制在 key 拼接 item.count！这样数量改变时，对应的一行会被底层彻底重绘！
              ForEach(this.cartList, (item: Product, index: number) => {
                this.CartItemRow(item, index)
              }, (item: Product) => `cart-item-${item.id}-${item.count}`)
            }
          }
        }

        // 猜你喜欢区
        ListItem() {
          Column() {
            Text("—— 猜你喜欢 ——").fontSize(12).fontColor(AppTheme.TEXT_HINT).margin(15)
            Grid() {
              ForEach(this.recommends, (item: Product) => {
                GridItem() {
                  Column() {
                    Image($rawfile(item.images[0])).width('100%').height(100).objectFit(ImageFit.Cover)
                      .onClick(() => router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams }))
                    Text(item.name).fontSize(11).maxLines(1).margin(5)
                      .onClick(() => router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams }))
                    Button("加购").fontSize(10).height(20).backgroundColor(AppTheme.PRIMARY)
                      .onClick(() => {
                        GlobalStore.addToCart(item);
                        this.refresh();
                      })
                  }
                  .backgroundColor(AppTheme.WHITE).borderRadius(8).padding(5)
                }
              })
            }.columnsTemplate('1fr 1fr').columnsGap(8).rowsGap(8).height(450)
          }
        }
      }
      .layoutWeight(1)
      .width('94%')

      // 3. 底部结算固定栏
      Row() {
        Row() {
          Image(this.isAllSelected ? $r('app.media.Select') : $r('app.media.unselect')).width(20).height(20).margin({ right: 4 })
          Text("全选").fontSize(14).fontColor(AppTheme.TEXT_PRIMARY)
        }
        .onClick(() => this.toggleSelectAll())
        .margin({ right: 16 })

        Text(`合计: ￥${this.total.toFixed(2)}`).fontColor(AppTheme.PRIMARY).fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)

        Button("立即结算")
          .backgroundColor(this.total > 0 ? AppTheme.PRIMARY : AppTheme.BTN_DISABLED)
          .enabled(this.total > 0)
          .onClick(() => { if (this.total > 0) this.goCheckout(); })
      }
      .width('100%').padding(20).backgroundColor(AppTheme.WHITE).shadow({ radius: 5, color: AppTheme.SHADOW, offsetY: -3 })
    }
    .backgroundColor(AppTheme.BG_PAGE).height('100%')
  }

  // 4. 重构后的单行组件
  @Builder
  CartItemRow(item: Product, index: number) {
    Row() {
      // 勾选单选框
      Column() {
        Image(this.selectedItems.has(item.id) ? $r('app.media.Select') : $r('app.media.unselect')).width(22).height(22)
          .onClick((e) => { this.toggleSelect(item); })
      }.padding({ right: 8 }).justifyContent(FlexAlign.Center)

      // 商品图片：已为您加上点击跳转详情页功能！
      Image($rawfile(item.images[0])).width(85).height(85).borderRadius(10)
        .backgroundColor(this.isPurchased(item) ? AppTheme.BG_DISABLED : AppTheme.BG_SECTION)
        .opacity(this.isPurchased(item) ? 0.6 : 1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams });
        })

      // 中间信息区
      Column() {
        if (this.isPurchased(item)) {
          Text('已购买过').fontSize(11).fontColor(AppTheme.TEXT_HINT).backgroundColor(AppTheme.BG_DISABLED).padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4).margin({ bottom: 4 })
        }

        // 商品名称：已为您加上点击跳转详情页功能！
        Text(item.name).fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.isPurchased(item) ? AppTheme.TEXT_HINT : AppTheme.TEXT_PRIMARY).maxLines(2)
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams });
          })

        Blank()

        Row() {
          Text(`￥${item.price}`).fontColor(this.isPurchased(item) ? AppTheme.TEXT_LIGHT : AppTheme.PRIMARY).fontSize(18).fontWeight(FontWeight.Bold)
          Blank()

          // 核心加减器：直接控制局部状态机，阻断一切外界干扰！
          Row() {
            Text('-').width(28).height(28).textAlign(TextAlign.Center).fontColor(this.isPurchased(item) ? AppTheme.TEXT_HINT : AppTheme.TEXT_PRIMARY)
              .onClick((e) => {
                if (item.count! > 1) {
                  // 1. 改变局部实体的数量值
                  item.count!--;
                  // 2. 同步通知她的全局数据库
                  GlobalStore.updateCartCount(item.id, item.count!);
                  // 3. 【极度关键】把修改后的对象重新回塞给数组，并用解构语法彻底刷新引用指针！
                  this.cartList[index] = item;
                  this.cartList = [...this.cartList];
                  // 4. 重新计算最新价格
                  this.calcTotal();
                }
              })

            Text(`${item.count}`).width(35).height(28).textAlign(TextAlign.Center).fontSize(13)
              .fontColor(this.isPurchased(item) ? AppTheme.TEXT_HINT : AppTheme.TEXT_PRIMARY)
              .backgroundColor(this.isPurchased(item) ? AppTheme.BG_DISABLED : AppTheme.BG_PAGE)

            Text('+').width(28).height(28).textAlign(TextAlign.Center).fontColor(this.isPurchased(item) ? AppTheme.TEXT_HINT : AppTheme.TEXT_PRIMARY)
              .onClick((e) => {
                // 1. 改变局部实体的数量值
                item.count!++;
                // 2. 同步通知她的全局数据库
                GlobalStore.updateCartCount(item.id, item.count!);
                // 3. 【极度关键】深度刷新数组引用
                this.cartList[index] = item;
                this.cartList = [...this.cartList];
                // 4. 重新计算最新价格
                this.calcTotal();
              })
          }
          .border({ width: 1, color: this.isPurchased(item) ? AppTheme.BORDER_INPUT : AppTheme.BG_SIDEBAR }).borderRadius(4)
        }.width('100%')
      }.layoutWeight(1).height(85).margin({ left: 12, right: 10 }).alignItems(HorizontalAlign.Start)

      // 删除按钮
      Column() {
        Text('删除').fontSize(12).fontColor(AppTheme.WHITE)
          .backgroundColor(this.isPurchased(item) ? AppTheme.BTN_DISABLED : AppTheme.PRIMARY).padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(6)
          .onClick((e) => {
            AlertDialog.show({
              title: '提示', message: '确定要移除这件商品吗？',
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: {
                value: '删除', fontColor: AppTheme.PRIMARY,
                action: () => {
                  GlobalStore.removeFromCartByProductId(item.id);
                  this.refresh();
                }
              }
            })
          })
      }.justifyContent(FlexAlign.Center)
    }
    .padding(12).backgroundColor(this.isPurchased(item) ? AppTheme.BG_SIDEBAR : AppTheme.WHITE).borderRadius(16).margin({ bottom: 12 }).shadow({ radius: 8, color: AppTheme.SHADOW_SOFT, offsetY: 4 })
  }
}