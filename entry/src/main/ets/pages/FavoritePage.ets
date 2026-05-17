// path: entry/src/main/ets/pages/FavoritePage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Product, GlobalStore, RouteParams } from '../model/Models';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct FavoritePage {
  @State favList: Product[] = [];
  @State recommends: Product[] = [];

  aboutToAppear() {
    this.refresh();
    this.recommends = GlobalStore.getRandomRecommend(6);
  }

  onPageShow() {
    this.refresh();
  }

  refresh() {
    // 触发 UI 响应式刷新的标准动作
    this.favList = [...GlobalStore.favoriteList];
  }

  build() {
    Column() {
      // 1. 顶部导航
      Row() {
        Text("首页").fontSize(16).fontColor(AppTheme.PRIMARY).fontWeight(FontWeight.Bold)
          .onClick(() => router.replaceUrl({ url: 'pages/HomePage' }))
        //Blank()
        Text("我的收藏").fontSize(18).fontWeight(FontWeight.Bold).padding({left: 100})
        Blank()
      }.width('100%').padding(15).backgroundColor(AppTheme.WHITE)

      // 2. 动态滚动区域
      List({ space: 15 }) {
        // A. 收藏列表
        ListItem() {
          if (!GlobalStore.isLoggedIn()) {
            Column() {
              Text("请先登录查看收藏").fontColor(AppTheme.TEXT_HINT).margin({ top: 30 })
              Button("去登录").backgroundColor(AppTheme.PRIMARY).margin(15)
                .onClick(() => router.pushUrl({ url: 'pages/Login' }))
            }.width('100%')
          } else if (this.favList.length === 0) {
            Column() {
              Text("收藏空空如也").fontColor(AppTheme.TEXT_HINT).margin({ top: 30 })
              Button("去逛逛").backgroundColor(AppTheme.PRIMARY).margin(15)
                .onClick(() => router.replaceUrl({ url: 'pages/HomePage' }))
            }.width('100%')
          } else {
            Column() {
              ForEach(this.favList, (item: Product, index: number) => {
                Row() {
                  Image($rawfile(item.images[0])).width(60).height(60).borderRadius(8)
                  Text(item.name).layoutWeight(1).margin({ left: 10 }).maxLines(1).fontSize(14)
                  Text("删除").fontColor(AppTheme.TEXT_HINT).fontSize(12).padding(10)
                    .onClick(() => {
                      GlobalStore.removeFromFavoriteByIndex(index);
                      this.refresh();
                    })
                }
                .padding(12).backgroundColor(AppTheme.WHITE).borderRadius(12).margin({ bottom: 10 })
                // 【核心修复】：为整行添加点击事件，跳转详情页
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ProductDetail',
                    params: { product: item } as RouteParams
                  })
                })
              })
            }
          }
        }

        // B. 猜你喜欢标题
        ListItem() {
          Text("—— 猜你喜欢 ——").width('100%').textAlign(TextAlign.Center).fontSize(12).fontColor(AppTheme.TEXT_HINT).margin({ top: 10 })
        }

        // C. 推荐网格流
        ListItem() {
          Grid() {
            ForEach(this.recommends, (item: Product) => {
              GridItem() {
                Column() {
                  Image($rawfile(item.images[0])).width('100%').height(110).objectFit(ImageFit.Cover)
                  Text(item.name).fontSize(12).maxLines(1).margin(5)
                  Button("收藏").fontSize(10).height(22).backgroundColor(AppTheme.PRIMARY)
                    .onClick(() => {
                      if (!GlobalStore.addToFavorite(item)) {
                        promptAction.showToast({ message: '请先登录后再收藏' });
                        router.pushUrl({ url: 'pages/Login' });
                        return;
                      }
                      promptAction.showToast({ message: '收藏成功' });
                      this.refresh();
                    })
                }
                .backgroundColor(AppTheme.WHITE).borderRadius(8).padding(5)
                // 推荐位的点击跳转
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ProductDetail',
                    params: { product: item } as RouteParams
                  })
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .height(500)
        }
      }
      .layoutWeight(1)
      .width('94%')
    }
    .backgroundColor(AppTheme.BG_PAGE).height('100%')
  }
}