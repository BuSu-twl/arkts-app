import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PayItem, Coupon, GlobalStore, PayRouteParams, PayResultParams } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct PayPage {
  @State payItems: PayItem[] = [];
  @State fromCart: boolean = false;
  @State subtotal: number = 0;
  @State discount: number = 0;
  @State payAmount: number = 0;
  @State selectedCouponId: string = '';
  @State usableCoupons: Coupon[] = [];
  @State payMethod: string = 'wechat';
  @State paying: boolean = false;
  @State userBalance: number = 0;

  aboutToAppear() {
    ensureAppData();
    const params = router.getParams() as PayRouteParams;
    if (params && params.items && params.items.length > 0) {
      this.payItems = GlobalStore.copyPayItems(params.items);
      this.fromCart = params.fromCart;
    } else {
      promptAction.showToast({ message: '订单信息无效' });
      router.back();
      return;
    }
    this.refreshBalance();
    this.recalcAmount();
  }

  onPageShow() {
    this.refreshBalance();
  }

  refreshBalance() {
    this.userBalance = GlobalStore.getUserBalance();
  }

  recalcAmount() {
    this.subtotal = GlobalStore.calcItemsTotal(this.payItems);
    this.usableCoupons = GlobalStore.getUsableCoupons(this.subtotal);
    if (this.selectedCouponId.length > 0 &&
      GlobalStore.calcCouponDiscount(this.subtotal, this.selectedCouponId) === 0) {
      this.selectedCouponId = '';
    }
    if (this.selectedCouponId.length === 0) {
      this.selectedCouponId = GlobalStore.getBestCouponId(this.subtotal);
    }
    this.discount = GlobalStore.calcCouponDiscount(this.subtotal, this.selectedCouponId);
    this.payAmount = GlobalStore.normalizeMoney(this.subtotal - this.discount);
    this.refreshBalance();
  }

  selectCoupon(couponId: string) {
    if (this.selectedCouponId === couponId) {
      this.selectedCouponId = '';
    } else {
      this.selectedCouponId = couponId;
    }
    this.recalcAmount();
  }

  doPay() {
    if (!GlobalStore.isLoggedIn()) {
      GlobalStore.setPendingPay({
        items: GlobalStore.copyPayItems(this.payItems),
        fromCart: this.fromCart
      });
      promptAction.showToast({ message: '请先登录，登录后将返回继续支付' });
      router.pushUrl({ url: 'pages/Login' });
      return;
    }
    if (this.payItems.length === 0) {
      promptAction.showToast({ message: '订单商品为空' });
      return;
    }
    if (this.paying) {
      return;
    }
    if (this.payMethod === 'balance') {
      this.refreshBalance();
      if (this.userBalance < this.payAmount) {
        promptAction.showToast({ message: '余额不足，请选择其他支付方式' });
        return;
      }
    }
    this.paying = true;
    setTimeout(() => {
      let order = GlobalStore.createOrder(this.payItems, this.selectedCouponId, this.payMethod);
      if (order === null) {
        this.paying = false;
        if (this.payMethod === 'balance') {
          promptAction.showToast({ message: '余额不足，支付未完成' });
        } else {
          promptAction.showToast({ message: '支付失败，请重试' });
        }
        return;
      }
      if (this.fromCart) {
        GlobalStore.removeCartItemsForPayItems(this.payItems);
      }
      this.paying = false;
      router.replaceUrl({
        url: 'pages/PayResultPage',
        params: { orderId: order.orderId, payAmount: order.payAmount } as PayResultParams
      });
    }, 1200);
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .onClick(() => {
            router.back();
          })
        Text('确认支付')
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

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 10 }) {
            Text('商品清单')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
            ForEach(this.payItems, (item: PayItem) => {
              Row({ space: 10 }) {
                Image($rawfile(item.image))
                  .width(64)
                  .height(64)
                  .borderRadius(8)
                  .backgroundColor(AppTheme.BG_DISABLED)
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(14)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text(`￥${item.price}`)
                      .fontSize(14)
                      .fontColor(AppTheme.PRIMARY)
                    Blank()
                    Text(`x${item.count}`)
                      .fontSize(12)
                      .fontColor(AppTheme.TEXT_HINT)
                  }
                  .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }, (item: PayItem) => `pay-${item.productId}`)
          }
          .width('92%')
          .padding(14)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(12)

          Column({ space: 10 }) {
            Text('优惠券')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
            if (this.usableCoupons.length === 0) {
              Text('暂无可用优惠券（请先在首页领取且满足满减门槛）')
                .fontSize(12)
                .fontColor(AppTheme.TEXT_HINT)
            } else {
              ForEach(this.usableCoupons, (coupon: Coupon) => {
                Row() {
                  Text(coupon.title)
                    .fontSize(14)
                    .fontColor(AppTheme.TEXT_PRIMARY)
                  Blank()
                  Text(this.selectedCouponId === coupon.id ? '已选' : '使用')
                    .fontSize(12)
                    .fontColor(this.selectedCouponId === coupon.id ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .onClick(() => {
                  this.selectCoupon(coupon.id);
                })
              }, (coupon: Coupon) => coupon.id)
            }
          }
          .width('92%')
          .padding(14)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('支付方式')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
            this.payMethodRow('wechat', '微信支付')
            this.payMethodRow('alipay', '支付宝')
            this.payBalanceRow()
          }
          .width('92%')
          .padding(14)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(12)

          Column({ space: 8 }) {
            Row() {
              Text('商品金额')
                .fontSize(14)
                .fontColor(AppTheme.TEXT_SECONDARY)
              Blank()
              Text(`￥${this.subtotal.toFixed(2)}`)
                .fontSize(14)
            }
            .width('100%')
            Row() {
              Text('优惠减免')
                .fontSize(14)
                .fontColor(AppTheme.TEXT_SECONDARY)
              Blank()
              Text(`-￥${this.discount.toFixed(2)}`)
                .fontSize(14)
                .fontColor(AppTheme.PRIMARY)
            }
            .width('100%')
            Row() {
              Text('应付金额')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Blank()
              Text(`￥${this.payAmount.toFixed(2)}`)
                .fontSize(20)
                .fontColor(AppTheme.PRIMARY)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ top: 4 })
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

      Column() {
        Button(this.paying ? '支付处理中...' : `确认支付 ￥${this.payAmount.toFixed(2)}`)
          .width('92%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.paying ? AppTheme.BTN_DISABLED : AppTheme.PRIMARY)
          .enabled(!this.paying && this.payItems.length > 0 &&
            !(this.payMethod === 'balance' && this.userBalance < this.payAmount))
          .onClick(() => {
            this.doPay();
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 20 })
      .backgroundColor(AppTheme.WHITE)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }

  @Builder
  payBalanceRow() {
    Column({ space: 4 }) {
      Row() {
        Text('余额支付')
          .fontSize(15)
        Blank()
        Text(this.payMethod === 'balance' ? '●' : '○')
          .fontSize(16)
          .fontColor(this.payMethod === 'balance' ? AppTheme.PRIMARY : AppTheme.BTN_DISABLED)
      }
      .width('100%')
      Row() {
        Text(`当前余额 ￥${this.userBalance.toFixed(2)}`)
          .fontSize(12)
          .fontColor(AppTheme.TEXT_HINT)
        if (this.payMethod === 'balance' && this.userBalance < this.payAmount) {
          Text('（不足）')
            .fontSize(12)
            .fontColor(AppTheme.PRIMARY)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      this.payMethod = 'balance';
    })
  }

  @Builder
  payMethodRow(method: string, label: string) {
    Row() {
      Text(label)
        .fontSize(15)
      Blank()
      Text(this.payMethod === method ? '●' : '○')
        .fontSize(16)
        .fontColor(this.payMethod === method ? AppTheme.PRIMARY : AppTheme.BTN_DISABLED)
    }
    .width('100%')
    .height(44)
    .onClick(() => {
      this.payMethod = method;
    })
  }
}
