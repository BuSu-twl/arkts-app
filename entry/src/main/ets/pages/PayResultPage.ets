import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore, PayResultParams } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct PayResultPage {
  @State orderId: string = '';
  @State payAmount: number = 0;
  @State payMethod: string = '';

  aboutToAppear() {
    ensureAppData();
    const params = router.getParams() as PayResultParams;
    if (params && params.orderId) {
      this.orderId = params.orderId;
      this.payAmount = params.payAmount ?? 0;
    } else {
      promptAction.showToast({ message: '支付结果无效' });
      router.replaceUrl({ url: 'pages/HomePage' });
      return;
    }
    let order = GlobalStore.getOrderById(this.orderId);
    if (order !== null) {
      this.payMethod = order.payMethod;
    }
  }

  getPayMethodLabel(): string {
    return GlobalStore.getPayMethodLabel(this.payMethod);
  }

  build() {
    Column({ space: 20 }) {
      Text('支付成功')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.PRIMARY)
        .margin({ top: 80 })

      Text('✓')
        .fontSize(48)
        .fontColor(AppTheme.PRIMARY)

      Column({ space: 8 }) {
        Text(`实付：￥${this.payAmount.toFixed(2)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
        if (this.getPayMethodLabel().length > 0) {
          Text(`支付方式：${this.getPayMethodLabel()}`)
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
        }
        Text(`订单号：${this.orderId}`)
          .fontSize(12)
          .fontColor(AppTheme.TEXT_HINT)
          .margin({ top: 8 })
      }
      .padding(20)
      .backgroundColor(AppTheme.WHITE)
      .borderRadius(12)
      .width('85%')

      Row({ space: 16 }) {
        Button('查看订单')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(AppTheme.WHITE)
          .fontColor(AppTheme.PRIMARY)
          .border({ width: 1, color: AppTheme.PRIMARY })
          .onClick(() => {
            router.replaceUrl({ url: 'pages/OrderListPage' });
          })

        Button('返回首页')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(AppTheme.PRIMARY)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/HomePage' });
          })
      }
      .width('85%')
      .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }
}
