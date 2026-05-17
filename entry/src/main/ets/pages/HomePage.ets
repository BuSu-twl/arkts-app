import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import productData from '../../../mock/product.json';
import { Product, Coupon, GlobalStore, RouteParams, ProductUtils } from '../model/Models';
import { BottomNavBar } from '../components/BottomNavBar';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct HomePage {
  private products: Product[] = productData.data as Product[];
  @State hotCarousel: Product[] = [];
  @State personalRecommends: Product[] = [];
  @State personalHint: string = '';
  @State categoryRecommends: Product[] = [];
  @State coupons: Coupon[] = GlobalStore.COUPONS;
  @State claimedIds: string[] = [];

  aboutToAppear() {
    GlobalStore.allProducts = this.products;
    this.hotCarousel = ProductUtils.getTopHotProducts(this.products, 5);
    this.categoryRecommends = ProductUtils.getCategoryTopProducts(this.products);
    this.refreshClaimed();
    this.refreshPersonalRecommends();
  }

  onPageShow() {
    this.refreshClaimed();
    this.refreshPersonalRecommends();
  }

  refreshPersonalRecommends() {
    this.personalRecommends = GlobalStore.getPersonalizedRecommend(6);
    this.personalHint = GlobalStore.getPersonalRecommendHint();
  }

  refreshClaimed() {
    this.claimedIds = GlobalStore.claimedCouponIds.slice();
  }

  goProductDetail(item: Product) {
    router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams });
  }

  addToCart(item: Product) {
    GlobalStore.addToCart(item);
    promptAction.showToast({ message: '已加入购物车' });
  }

  claimCoupon(coupon: Coupon) {
    if (!GlobalStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录后再领取优惠券' });
      router.pushUrl({ url: 'pages/Login' });
      return;
    }
    if (GlobalStore.isCouponClaimed(coupon.id)) {
      promptAction.showToast({ message: '该优惠券已领取' });
      return;
    }
    GlobalStore.claimCoupon(coupon.id);
    this.refreshClaimed();
    promptAction.showToast({ message: `${coupon.title} 领取成功` });
  }

  isClaimed(couponId: string): boolean {
    for (let i = 0; i < this.claimedIds.length; i++) {
      if (this.claimedIds[i] === couponId) {
        return true;
      }
    }
    return false;
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          Text('精选商城')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 4 })

          if (this.hotCarousel.length > 0) {
            Swiper() {
              ForEach(this.hotCarousel, (item: Product) => {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image($rawfile(item.images[0]))
                    .width('100%')
                    .height(180)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(12)
                    .backgroundColor(AppTheme.BG_DISABLED)
                  Column() {
                    Text(item.name)
                      .fontSize(13)
                      .fontColor(AppTheme.WHITE)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(`￥${item.price}  ·  ${item.hot}`)
                      .fontSize(12)
                      .fontColor(AppTheme.PRIMARY_TEXT_SOFT)
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor(AppTheme.PRIMARY_OVERLAY)
                }
                .width('100%')
                .height(180)
                .onClick(() => {
                  this.goProductDetail(item);
                })
              }, (item: Product) => `${item.id}`)
            }
            .autoPlay(true)
            .interval(3000)
            .indicator(true)
            .loop(true)
            .width('92%')
            .height(180)
            .borderRadius(12)
          }

          Column({ space: 10 }) {
            Row() {
              Text('优惠券')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('点击领取')
                .fontSize(12)
                .fontColor(AppTheme.TEXT_HINT)
                .margin({ left: 8 })
            }
            .width('100%')

            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.coupons, (coupon: Coupon) => {
                  Column({ space: 6 }) {
                    Text(`￥${coupon.discount}`)
                      .fontSize(20)
                      .fontColor(AppTheme.PRIMARY)
                      .fontWeight(FontWeight.Bold)
                    Text(coupon.title)
                      .fontSize(11)
                      .fontColor(AppTheme.TEXT_SECONDARY)
                    Text(this.isClaimed(coupon.id) ? '已领取' : '立即领取')
                      .fontSize(11)
                      .fontColor(this.isClaimed(coupon.id) ? AppTheme.TEXT_HINT : AppTheme.WHITE)
                      .backgroundColor(this.isClaimed(coupon.id) ? AppTheme.BG_DISABLED : AppTheme.PRIMARY)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .borderRadius(12)
                      .margin({ top: 4 })
                  }
                  .width(110)
                  .padding(12)
                  .backgroundColor(AppTheme.PRIMARY_LIGHT)
                  .borderRadius(10)
                  .border({ width: 1, color: AppTheme.PRIMARY_BORDER })
                  .onClick(() => {
                    this.claimCoupon(coupon);
                  })
                }, (coupon: Coupon) => coupon.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('92%')
          .padding(14)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(12)

          if (this.personalRecommends.length > 0) {
            Column({ space: 10 }) {
              Row() {
                Text('为你推荐')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Text(this.personalHint)
                  .fontSize(11)
                  .fontColor(AppTheme.TEXT_HINT)
                  .margin({ left: 8 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .width('100%')

              Grid() {
                ForEach(this.personalRecommends, (item: Product) => {
                  GridItem() {
                    Column({ space: 6 }) {
                      Image($rawfile(item.images[0]))
                        .width('100%')
                        .aspectRatio(1)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(8)
                        .backgroundColor(AppTheme.BG_DISABLED)
                        .onClick(() => {
                          this.goProductDetail(item);
                        })
                      Text(item.category ?? '推荐')
                        .fontSize(11)
                        .fontColor(AppTheme.PRIMARY)
                      Text(item.name)
                        .fontSize(12)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .onClick(() => {
                          this.goProductDetail(item);
                        })
                      Row() {
                        Text(`￥${item.price}`)
                          .fontSize(14)
                          .fontColor(AppTheme.PRIMARY)
                          .fontWeight(FontWeight.Medium)
                          .layoutWeight(1)
                        Button('加购')
                          .fontSize(11)
                          .height(26)
                          .padding({ left: 10, right: 10 })
                          .backgroundColor(AppTheme.PRIMARY)
                          .onClick(() => {
                            this.addToCart(item);
                          })
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                }, (item: Product) => `personal-${item.id}`)
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)
              .width('100%')
            }
            .width('92%')
            .padding(14)
            .backgroundColor(AppTheme.WHITE)
            .borderRadius(12)
          }

          Column({ space: 10 }) {
            Text('分类精选推荐')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Grid() {
              ForEach(this.categoryRecommends, (item: Product) => {
                GridItem() {
                  Column({ space: 6 }) {
                    Image($rawfile(item.images[0]))
                      .width('100%')
                      .aspectRatio(1)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                      .backgroundColor(AppTheme.BG_DISABLED)
                      .onClick(() => {
                        this.goProductDetail(item);
                      })
                    Text(item.category ?? '推荐')
                      .fontSize(11)
                      .fontColor(AppTheme.PRIMARY)
                    Text(item.name)
                      .fontSize(12)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .onClick(() => {
                        this.goProductDetail(item);
                      })
                    Row() {
                      Text(`￥${item.price}`)
                        .fontSize(14)
                        .fontColor(AppTheme.PRIMARY)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                      Button('加购')
                        .fontSize(11)
                        .height(26)
                        .padding({ left: 10, right: 10 })
                        .backgroundColor(AppTheme.PRIMARY)
                        .onClick(() => {
                          this.addToCart(item);
                        })
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  .alignItems(HorizontalAlign.Start)
                }
              }, (item: Product) => `rec-${item.id}`)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
          }
          .width('92%')
          .padding(14)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(12)
          .margin({ bottom: 16 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      BottomNavBar({ currentIndex: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }
}
