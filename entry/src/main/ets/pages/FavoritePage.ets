// path: entry/src/main/ets/pages/FavoritePage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Product, GlobalStore, RouteParams, ProductUtils } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct FavoritePage {
  @State favList: Product[] = [];
  @State recommends: Product[] = [];

  aboutToAppear() {
    ensureAppData();
    this.refresh();
    this.recommends = GlobalStore.getPersonalizedRecommend(6);
  }

  onPageShow() {
    this.refresh();
  }

  refresh() {
    // 触发 UI 响应式刷新的标准动作
    this.favList = [...GlobalStore.favoriteList];
  }

  goBack(): void {
    try {
      router.back();
    } catch (e) {
      router.replaceUrl({ url: 'pages/MySetting' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .onClick(() => {
            this.goBack();
          })
        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('首页')
          .fontSize(14)
          .fontColor(AppTheme.PRIMARY)
          .width(48)
          .textAlign(TextAlign.End)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/HomePage' });
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppTheme.WHITE)

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
                  Image($rawfile(ProductUtils.getProductImageFile(item)))
                    .width(60).height(60).borderRadius(8)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/ProductDetail',
                        params: { product: item } as RouteParams
                      });
                    })
                  Text(item.name).layoutWeight(1).margin({ left: 10 }).maxLines(1).fontSize(14)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/ProductDetail',
                        params: { product: item } as RouteParams
                      });
                    })
                  Text("删除").fontColor(AppTheme.TEXT_HINT).fontSize(12).padding(10)
                    .onClick(() => {
                      GlobalStore.removeFromFavoriteByIndex(index);
                      this.refresh();
                    })
                }
                .padding(12).backgroundColor(AppTheme.WHITE).borderRadius(12).margin({ bottom: 10 })
              }, (item: Product) => `fav-${item.id}`)
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
                  Image($rawfile(ProductUtils.getProductImageFile(item))).width('100%').height(110).objectFit(ImageFit.Cover)
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
            }, (item: Product) => `fav-rec-${item.id}`)
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