import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Coupon, GlobalStore } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct CouponPage {
  @State myCoupons: Coupon[] = [];
  @State claimableCoupons: Coupon[] = [];
  @State isLoggedIn: boolean = false;

  aboutToAppear() {
    ensureAppData();
    this.refreshCoupons();
  }

  onPageShow() {
    this.refreshCoupons();
  }

  refreshCoupons() {
    this.isLoggedIn = GlobalStore.isLoggedIn();
    if (this.isLoggedIn) {
      GlobalStore.syncClaimedCouponsFromCurrentUser();
    }
    this.myCoupons = GlobalStore.getClaimedCoupons();
    this.claimableCoupons = GlobalStore.getUnclaimedCoupons();
  }

  goBack(): void {
    try {
      router.back();
    } catch (e) {
      router.replaceUrl({ url: 'pages/MySetting' });
    }
  }

  claimCoupon(coupon: Coupon): void {
    if (!GlobalStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/Login' });
      return;
    }
    if (GlobalStore.isCouponClaimed(coupon.id)) {
      promptAction.showToast({ message: '该优惠券已领取' });
      this.refreshCoupons();
      return;
    }
    GlobalStore.claimCoupon(coupon.id);
    promptAction.showToast({ message: `${coupon.title} 领取成功` });
    this.refreshCoupons();
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
        Text('我的优惠券')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('')
          .width(48)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppTheme.WHITE)

      if (!this.isLoggedIn) {
        Column({ space: 12 }) {
          Text('请先登录查看已领取的优惠券')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_HINT)
          Button('去登录')
            .backgroundColor(AppTheme.PRIMARY)
            .onClick(() => {
              router.pushUrl({ url: 'pages/Login' });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Text(`已领取 ${this.myCoupons.length} 张，结算时满足门槛即可使用`)
              .fontSize(13)
              .fontColor(AppTheme.TEXT_HINT)
              .width('100%')
              .padding({ left: 4, right: 4 })

            if (this.myCoupons.length === 0) {
              Column({ space: 10 }) {
                Text('暂无已领取的优惠券')
                  .fontSize(14)
                  .fontColor(AppTheme.TEXT_HINT)
                Text('可在下方领取，或前往首页领券')
                  .fontSize(12)
                  .fontColor(AppTheme.TEXT_LIGHT)
              }
              .width('100%')
              .padding(24)
              .backgroundColor(AppTheme.WHITE)
              .borderRadius(12)
            } else {
              ForEach(this.myCoupons, (coupon: Coupon) => {
                this.CouponCard(coupon, true)
              }, (coupon: Coupon) => `mine-${coupon.id}`)
            }

            if (this.claimableCoupons.length > 0) {
              Text('可领取')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ top: 8 })

              ForEach(this.claimableCoupons, (coupon: Coupon) => {
                this.CouponCard(coupon, false)
              }, (coupon: Coupon) => `claim-${coupon.id}`)
            }
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }

  @Builder
  CouponCard(coupon: Coupon, owned: boolean) {
    Row() {
      Column({ space: 4 }) {
        Text(`￥${coupon.discount}`)
          .fontSize(22)
          .fontColor(AppTheme.PRIMARY)
          .fontWeight(FontWeight.Bold)
        Text(`满${coupon.threshold}可用`)
          .fontSize(12)
          .fontColor(AppTheme.TEXT_HINT)
      }
      .width(88)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 6 }) {
        Text(coupon.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.TEXT_PRIMARY)
        Text(owned ? '已领取 · 支付页自动匹配可用券' : '点击右侧按钮领取')
          .fontSize(12)
          .fontColor(AppTheme.TEXT_HINT)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      if (owned) {
        Text('已持有')
          .fontSize(12)
          .fontColor(AppTheme.PRIMARY)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(AppTheme.PRIMARY_LIGHT)
          .borderRadius(8)
      } else {
        Text('领取')
          .fontSize(12)
          .fontColor(AppTheme.TEXT_ON_PRIMARY)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(AppTheme.PRIMARY)
          .borderRadius(8)
          .onClick(() => {
            this.claimCoupon(coupon);
          })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.WHITE)
    .borderRadius(12)
    .border({ width: 1, color: AppTheme.PRIMARY_BORDER })
    .margin({ bottom: 10 })
  }
}
