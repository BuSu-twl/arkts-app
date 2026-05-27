// path: entry/src/main/ets/pages/ProductDetail.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Product, GlobalStore, RouteParams, PayRouteParams } from '../model/Models';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct ProductDetail {
  @State item: Product = {
    id: 0, name: '', price: 0, description: '',
    images: [], shopname: '', hot: ''
  };

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.product) {
      this.item = params.product;
      GlobalStore.recordBrowse(this.item.id);
    }
  }

  build() {
    Column() {
      // 1. 顶部大图区 (保持不变)
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.item.images.length > 0) {
          Image($rawfile(this.item.images[0]))
            .width('100%')
            .height(350)
            .objectFit(ImageFit.Contain)
            .backgroundColor(AppTheme.BG_SECTION)
        } else {
          Column()
            .width('100%')
            .height(350)
            .backgroundColor(AppTheme.BG_SECTION)
        }

        // 返回按钮
        Circle({ width: 40, height: 40 }).fill(AppTheme.OVERLAY_BACK).margin(15).onClick(() => router.back())
        Text("<").fontColor(AppTheme.WHITE).fontSize(20).margin({ left: 28, top: 22 }).onClick(() => router.back())
      }

      // 2. 滚动内容区
      Scroll() {
        Column() {
          // 价格与热度
          Row() {
            Text(`￥`).fontSize(18).fontColor(AppTheme.PRIMARY).margin({ top: 5 })
            Text(`${this.item.price}`).fontSize(28).fontColor(AppTheme.PRIMARY).fontWeight(FontWeight.Bold)
            Blank()
            Text(this.item.hot).fontSize(12).fontColor(AppTheme.TEXT_HINT).backgroundColor(AppTheme.BG_PAGE).padding(5).borderRadius(4)
          }.width('100%').alignItems(VerticalAlign.Bottom)

          // 商品标题
          Text(this.item.name).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 15 }).lineHeight(24)

          // 店铺名片区
          Row() {
            Circle({ width: 45, height: 45 }).fill(AppTheme.BG_DISABLED)
            Column() {
              Text(this.item.shopname).fontSize(15).fontWeight(FontWeight.Medium)
              Text("进店逛逛 >").fontSize(12).fontColor(AppTheme.TEXT_HINT).margin({ top: 3 })
            }.margin({ left: 12 }).alignItems(HorizontalAlign.Start)
            Blank()
            Button("关注").fontSize(12).height(28).width(60).backgroundColor(AppTheme.WHITE)
              .fontColor(AppTheme.PRIMARY).border({ width: 1, color: AppTheme.PRIMARY })
          }
          .width('100%').margin({ top: 20, bottom: 20 }).padding(15).backgroundColor(AppTheme.BG_SECTION).borderRadius(12)

          // 详情描述
          Text("商品详情").fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 10, bottom: 10 })
          Text(this.item.description).fontSize(14).fontColor(AppTheme.TEXT_BODY).lineHeight(22).margin({ bottom: 100 })
        }
        .padding(20).alignItems(HorizontalAlign.Start)
      }.layoutWeight(1)

      // 3. 底部悬浮工具栏 (补回了收藏功能！)
      Row() {
        // 客服图标 (示意)
        Column() { Image($r('app.media.waiter')).width(20).height(20); Text("客服").fontSize(10) }.margin({ right: 15 })

        // 收藏按钮
        Column() {
          Image($r('app.media.star')).width(20).height(20)//grayscale(1) // 灰色示意未收藏
          Text("收藏").fontSize(10)
        }
        .margin({ right: 20 })
        .onClick(() => {
          if (!GlobalStore.addToFavorite(this.item)) {
            promptAction.showToast({ message: '请先登录后再收藏' });
            router.pushUrl({ url: 'pages/Login' });
            return;
          }
          AlertDialog.show({ message: '收藏成功！' });
        })

        Blank()

        // 操作按钮：加入购物车
        Button("加入购物车")
          .backgroundColor(AppTheme.WHITE)
          .fontColor(AppTheme.PRIMARY)
          .border({ width: 1, color: AppTheme.PRIMARY })
          .height(45)
          .layoutWeight(1)
          .margin({ right: 10 })
          .onClick(() => {
            GlobalStore.addToCart(this.item);
            AlertDialog.show({ message: '已加入购物车' });
          })

        // 操作按钮：立即购买
        Button("立即购买")
          .backgroundColor(AppTheme.PRIMARY)
          .fontColor(AppTheme.TEXT_ON_PRIMARY)
          .height(45)
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/PayPage',
              params: {
                items: [GlobalStore.toPayItem(this.item, 1)],
                fromCart: false
              } as PayRouteParams
            });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(AppTheme.WHITE)
      .shadow({ radius: 10, color: AppTheme.SHADOW, offsetY: -5 })
    }
    .backgroundColor(AppTheme.WHITE)
    .height('100%')
  }
}